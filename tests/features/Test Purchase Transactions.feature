Feature: Determine ability to purchase
In order for a customer to make a purchase, they must have at least as much money as the price of the item they wish to purchase.

  Scenario: I have enough to purchase the item
    Given I have have $20.00
    And the sell price is $3.25
    When I pay for the item
    Then I should have $16.75 left over

  Scenario: I don't have enough to purchase the item
    Given I have have $20.00
    And the sell price is $40.00
    When I pay for the item
    Then the result should be 'You don't have enough'