component accessors = "true" extends = "tests.utils.Cucumber" {
    public function run(){
        var registerService = new services.cashRegister();

        // Step handlers (this is where tests happen)
        this.setStepDefinitions({
            // Sample "GIVEN"
            "I have have \$(.*)": function(arg1){
                $world.money = arg1;
            },
            // Sample "AND"
            "the sell price is \$(.*?)": function(arg1){
                $world.price = arg1;
            },
            "I have have a taxable item": function(){
                $world.taxable = true;
            },
            "I have have a non-taxable item": function(){
                $world.taxable = false;
            },
            "the sales tax is (.*?)%": function(arg1){
                $world.taxRate = arg1/100;
            },

            // Sample "WHEN" (where we run the function we are testing)
            "^I pay for the item$": function(){
                $world.result = registerService.makeTransaction( $world.price, $world.money);
            },
            "^I calculate the item price$": function(){
                $world.result = registerService.calculatePrice( $world.price, $world.taxable, $world.taxRate );
            },


            // Sample "THEN" (where we run the assertion testing)
            "^I should have \$(.*?) left over$": function(arg1){
                expect($world.result).toBe(arg1);
            },
            "^the result should be '(.*)'$": function(arg1){
                expect($world.result).toBe(arg1);
            },
            "^the total price should be \$(.*)$": function(arg1){
                expect($world.result).toBe(arg1);

            }
        });
        runFeatures(
            featurePath = expandPath("/tests/features/"),
            stepDefinitions = stepDefinitions,
            world = { price:0, money:0, taxable:false, taxrate:0 }
        );
    }

}