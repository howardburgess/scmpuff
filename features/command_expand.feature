Feature: command expansion at command line

  Background:
    Given a mocked home directory
    Given I override the environment variables to:
      | variable | value |
      | e1       | a.txt |
      | e2       | b.txt |
      | e3       | c.txt |
      | e4       | d.txt |
      | e5       | e.txt |
      | e6       | f.txt |

  Scenario: Expand single digit case
    When I successfully run `scmpuff expand 1`
    Then the output should contain exactly "a.txt\n"

  Scenario: Expand multiple digit case
    When I successfully run `scmpuff expand 1 2 6`
    Then the output should match /a.txt\tb.txt\tf.txt/

  Scenario: Expand complex case with range
    When I successfully run `scmpuff expand 6 3-4 1`
    Then the output should match /f.txt\tc.txt\td.txt\ta.txt/

  @wip
  Scenario: Dont expand files or directories with numeric names
    Given an empty file named "1"
    Given a directory named "2"
    When I successfully run `scmpuff expand 3 2 1`
      Then the output should contain "c.txt"
      But the output should not contain "b.txt"
      And the output should not contain "a.txt"

  Scenario: Dont interfere with CLI "options" that are passed along after `--`
    When I successfully run `scmpuff expand -- git foo -x 1`
    Then the output should match /git\tfoo\t-x\ta.txt/

  Scenario: Make sure args with spaces get escaped on way back
    When I successfully run `scmpuff expand -- git xxx "foo bar" 1`
    Then the output should match /git\txxx\tfoo\\ bar\ta.txt/

  Scenario: Verify filenames with stupid characters are properly escaped
    Given I override the environment variables to:
      | variable | value        |
      | e1       | so(dumb).jpg |
    When I successfully run `scmpuff expand 1`
    Then the output should match /so\\\(dumb\\\)\.jpg/