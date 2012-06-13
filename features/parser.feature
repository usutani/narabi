Feature: Parser
  Scenario: Parse text area
    Given the client posts following text:
      """
      User->System: Login Request
      System-->User: Response
      """
    When the system parse posted text
    Then the system should have <2> instances and <2> messages
    And the system should create following instances:
      | order | name   |
      | 0     | User   |
      | 1     | System |
    And the system should create following messages:
      | order | body          |
      | 0     | Login Request |
      | 1     | Response      |
