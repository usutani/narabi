Feature: See Help page
  Scenario: See example of messages
    Given there is a Help page
    When I visit the page for Help
    Then I should see "Messages" title
    And I should see "Changing the order of instances" title
    And I should see "Back to Home" link
