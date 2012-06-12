Feature: REST API
  Scenario: Instances list
    Given the system knows about the following instances:
      | order | name   |
      | 0     | User   |
      | 1     | System |
    When the client requests GET /instances.json
    Then the response should be JSON:
      """
      [
        {"name": "User",    "order": 0},
        {"name": "System",  "order": 1}
      ]
      """
