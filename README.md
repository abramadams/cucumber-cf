# Cucumber-cf
Cucumber implementation in CFML

# Installing and Running the Tests

To run tests, you'll need [CommandBox](https://www.ortussolutions.com/products/commandbox) installed.

Then run `box install` once to install the dependencies (TestBox is the only one currently).

Then start a CFML server via CommandBox:

`box start`

This will start Lucee5 on port 8800 and open a browser, running the Testbox runner. (__Note__: you can change the CFML engine and port in `server.json` or using CommandBox arguments)

You can also run the tests via command line:

`box testbox run verbose=false`

If you get any failures, you can run this with more verbose, but still compact output:

`box testbox run reporter=mintext`

# Using Cucumber-cf in your project

To install in your own project, simply drop the `/utils/Cucumber.cfc` file into your project and extend it from the cfc you'll use to define the steps.

To use in the project, extend the Cucumber.cfc from your test "spec" cfc: (see `/tests/specs/cucumberRunner.cfc` for an example).  Then define the `stepDefinitions` to handle the test scenarios in your feature files.
```javascript
component accessors = "true" extends = "tests.utils.Cucumber" {

    function run() {
        // Step handlers (this is where tests happen)
        this.setStepDefinitions({
            // Sample "GIVEN"
            "I have have \$(.*)": function(arg1){
                $world.money = arg1;
            },
            // Sample "WHEN" (where we run the function we are testing)
            "^I pay for the item$": function(){
                $world.result = request.registerService.makeTransaction(
                    $world.price,
                    $world.money
                );
            },
            // Sample "THEN" (where we run the assertion testing)
            "^I should have \$(.*?) left over$": function(arg1){
                expect($world.result).toBe(arg1);
            }
        });
        // Run all features
        runFeatures(
            featurePath = expandPath("/tests/features/"),
            stepDefinitions = stepDefinitions,
            world = { price:0, money:0, taxable:false, taxrate:0 }
        );
    }

}
```

Then, within the `run` method (a Testbox lifecycle method), call `runFeatures()` (see above)

## stepDefinitions
This variable is a struct containing the step definitions that will handle the test steps identified in the feature file.  Each item in the struct has a key:value pattern of `"regex string":function`.  The regex string will be matched against the feature file to see if any step is covered by the specific item and if so, the `function` will be executed.  Cucumber-cf will parse each feature file, one scenario at a time, line by line, checking each line against these definitions.
```javascript
this.setStepDefinitions({
    // Sample "GIVEN"
    "I have have \$(.*)": function(arg1){
        $world.money = arg1;
    },
    // Sample "WHEN" (where we run the function we are testing)
    "^I pay for the item$": function(){
        $world.result = request.registerService.makeTransaction(
            $world.price,
            $world.money
        );
    },
    // Sample "THEN" (where we run the assertion testing)
    "^I should have \$(.*?) left over$": function(arg1){
        expect($world.result).toBe(arg1);
    }
});
```
Each step definition function will be injected with arguments for any capture groups defined in the regex.  These are named `arg` with an incrementing number depending on how many capture groups there are.  So a regex like `I have \$(.*) and want \$(.*)` will inject two arguments `arg1` and `arg2`.  If the step in the scenario was: `I have $30 and I want $300`, then `arg1` would be `30` and `arg2` would be `300`.

To expose state to other steps within a single scenario you have access to the `$world` variable within your `stepDefinitions`.  This allows you to piece together state and use that state to test the scenario.  This `$world` object optionally gains it's initial state from the `runFeatures` function, which is reset for every scenario. This variables should also be used as the `results` container that you run the `expect` assertion against.  For instance:
```
expect($world.result).toBe(arg1);
```
Where `$world.result` was defined in a "WHEN" step definition.

## runFeatures
The runFeatures function kicks off the entire process.  It accepts the following arguments:

 * __featurePath__ - Absolute path of feature files to run, or an array of feature file paths to run.
 * __stepDefinitions__ - These are the actuall regex:function steps that will be used to match steps in the scenario and run the corresponding function to complete the step
 * __world__ - The initial state to be used for each scenario.  Each scenario will affect it's private world state and expose to the runner via $world variable.
 * __beforeScenario__ - Function to be run before each scenario
 * __afterScenario__ - Function to be run after each scenario

```javascript
runFeatures(
    featurePath = expandPath("/tests/features/"),
    stepDefinitions = stepDefinitions,
    world = { price:0, money:0, taxable:false, taxrate:0 }
);
```
# Copyright and License

Copyright (c) 2018 Abram Adams. All rights reserved.
The use and distribution terms for this software are covered by the Apache Software License 2.0 (http://www.apache.org/licenses/LICENSE-2.0) which can also be found in the file LICENSE at the root of this distribution and in individual licensed files.
By using this software in any fashion, you are agreeing to be bound by the terms of this license. You must not remove this notice, or any other, from this software.