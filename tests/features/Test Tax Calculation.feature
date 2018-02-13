Feature: Calculate Tax for item
In order for a retialer to sell a product, they must include the sales tax.

  Scenario: If I sell a taxable item in an area where sales tax is required, the tax should be calculated and added to the item price.
    Given I have have a taxable item
    And the sell price is $3.25
    And the sales tax is 8%
    When I calculate the item price
    Then the total price should be $3.51

  Scenario: If I sell a non-taxable item in an area where sales tax is required, the tax should be calculated and added to the item price.
    Given I have have a non-taxable item
    And the sell price is $3.25
    When I calculate the item price
    Then the total price should be $3.25

  Scenario: BROKEN ON PURPOSE. If I sell a non-taxable item in an area where sales tax is required, the tax should be calculated and added to the item price.
    Given I have have a non-taxable item
    And the sell price is $7.33
    When I calculate the item price
    Then the total price should be $7.25