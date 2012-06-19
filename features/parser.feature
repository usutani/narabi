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

  Scenario: Changing the order of instances
    Given the client posts following text:
      """
      instance User
      instance System

      note System: This is a note.
      User->System: Login Request
      System->User: Response
      """
    When the system parse posted text
    Then the system should have <2> instances and <3> messages
    And the system should create following instances:
      | order | name   |
      | 0     | User   |
      | 1     | System |
    And the system should create following messages:
      | order | body            |
      | 0     | This is a note. |
      | 1     | Login Request   |
      | 2     | Response        |

  Scenario: Title and Shortened name
    Given the client posts following text:
      """
      title Subject to change w/o notice

      instance User             as U
      instance Long name System as S

      note S: This is a note.
      U->S: Login Request
      S->U: Response
      """
    When the system parse posted text
    Then the system should have <2> instances and <3> messages
    And the diagram title should be <"Subject to change w/o notice">
    And the system should create following instances:
      | order | name             |
      | 0     | User             |
      | 1     | Long name System |
    And the system should create following messages:
      | order | body            |
      | 0     | This is a note. |
      | 1     | Login Request   |
      | 2     | Response        |
