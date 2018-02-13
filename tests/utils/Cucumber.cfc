/************************************************************
*
*	Copyright (c) 2018, Abram Adams
*
*	Licensed under the Apache License, Version 2.0 (the "License");
*	you may not use this file except in compliance with the License.
*	You may obtain a copy of the License at
*
*		http://www.apache.org/licenses/LICENSE-2.0
*
*	Unless required by applicable law or agreed to in writing, software
*	distributed under the License is distributed on an "AS IS" BASIS,
*	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*	See the License for the specific language governing permissions and
*	limitations under the License.
*
***********************************************************/
component accessors="true" extends = "testbox.system.BaseSpec" {
    property stepDefinitions;
    /**
     * Run the feature(s).  This will run each feature and parse out individual steps then execute the test.
     *
     * @featurePath Abbsolute path of feature files to run, or an array of feature file paths to run.
     * @stepDefinitions These are the actuall regex:function steps that will be used to match steps in the scenario and run the corresponding function to complete the step
     * Sample Usage (from step runner):
     * this.setStepDefinitions({
     *  "I have have \$(.*)": function(arg1){
     *    $world.money = arg1;
     *  },
     *  "The item I want to buy costs \$(.*?)": function(arg1){
     *    $world.price = arg1;
     *  }
     * });
     * @world The initial state to be used for each scenario.  Each scenario will affect it's private world state and expose to the runner via $world variable.
     * @beforeScenario Function to be run before each scenario
     * @afterScenario Function to be run after each scenario
     */
    function runFeatures(required any featurePath, required struct stepDefinitions, struct world = {}, beforeScenario, afterScenario ) {
        if( isArray(featurePath) ){
            var features = featurePath;
        }else{
            var features = directoryList(featurePath);
        }
        features.each(function(featureFile){
            var feature = fileRead(featureFile);
            var featureTitle = feature.mid(1, feature.findNoCase('Scenario:') - 1);
            describe( title=featureTitle, body = function(){
                var start = feature.findNoCase("Scenario:");
                var scenarios = feature.mid(start, feature.len());
                scenarios = scenarios.replaceNoCase("Scenario:", chr(989) & "Scenario:", "all").listToArray(chr(989));
                scenarios.each(function(scenario){
                    if( !isNull( beforeScenario) &&  isCustomFunction(beforeScenario) ) beforeScenario();
                    describe(scenario, function(){
                        parseScenario(scenario, stepDefinitions, duplicate( world ));
                    });
                    if( !isNull(afterScenario) && isCustomFunction(afterScenario) ) afterScenario();
                });
            });
        });
    }
    /**
     * This will parse each Gherkin scenario and execute it's step
     *
     * @scenario The scenario we are parsing/executing
     * @stepDefinitions The possible steps we will execute based on the step in the scenario
     * @world World is an isolated context for each scenario, exposed to the hooks and steps as this. This is where your steps will setup state for the "when" and "then" steps.  This is injected to the calling test runner step as $world.
     */
    function parseScenario(scenario, stepDefinitions, world) {
        var result = {};
        var stepResults = [];
        // Each line in the scenario indicates an individual step.
        // Steps either setup state, or execute assertion tests.
        for (var line in scenario.listToArray(chr(10))) {
            // The first line in a scenario is simply the description of the scenario.
            // We'll pull that out and use it later as the "describe" method's title.
            if (line.trim().listFirst(':') == "Scenario") {
                result.title = line.listRest(':');
                continue;
            }
            // ignore blank lines.
            if (!line.trim().len()) continue;

            var step = line.trim().listRest(' ');
            var stepType = line.trim().listFirst(' ');
            // steps are defined as regex keys that will be tested against the
            // step text. If a match is found we'll execute that steps function.
            var matched = stepDefinitions.filter(function(key){
                return reFindNoCase(key, step);
            });
            // If not found, we'll throw an error.
            if (isNull(matched)) throw ('no step defined');

            // We found at least one match.  We must only allow a single match, so
            // we'll throw an error if more than one.
            if (matched.size() == 1) {

                var stepAction = stepDefinitions[matched.keyList()];
                var stepTitle = stepType & " " & step.reMatch(matched.keyList())[1];
                // Pull out the args from the step description based on the regex
                var stepArgs = step.reReplaceNoCase(
                                    matched.keyList(),
                                    '\1#chr(999)#\2#chr(999)#\3#chr(999)#\4#chr(999)#\5'
                                ).listToArray(chr(999)).reduce(
                                    function(prev, cur){
                                    prev["arg#prev.size()+1#"] = cur.toString();
                                    return prev;
                                }, {});
                stepArgs.$world = world;
                stepArgs.$scenario = scenario;
                // Execute step
                it(
                    title = stepTitle,
                    data = {
                        stepTitle: stepTitle,
                        stepType: stepType,
                        stepArgs: stepArgs,
                        stepAction: stepAction
                    },
                    body = function(data){
                        var stepArgs = data.stepArgs;
                        stepResults.append({
                            "title": data.stepTitle,
                            "type": data.stepType,
                            "results": data.stepAction(argumentCollection: stepArgs) ? : true
                    });
                });

            } else {
                // Either no match, or more than one match: throw error.
                if (matched.size() == 0) {
                    throw ("No matching steps for #line# in #chr(13)# #scenario#");
                } else {
                    throw ("Too many steps match criteria: #matched.keyList()#::#scenario#");
                }
            }
        }
        result.stepResults = stepResults;
        return result;
    }


    /**
     * Helper function to add a single definition to the existing definitions
     *
     * @stepDefinition Struct containing "regex":function to handle step.
     */
    function addStepDefinition( required struct stepDefinition ){
        var stepDefs = getStepDefinitions();
        stepDefs.append( stepDefinition, true );
        setSTepDefinitions( stepDefs );
    }
}