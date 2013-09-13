#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

Feature: Copying an work package can copy over the watchers
  Background:
    Given there is 1 project with the following:
      | identifier | omicronpersei8 |
      | name       | omicronpersei8 |
    And I am working in project "omicronpersei8"
    And there is a role "CanCopyPackages"
    And the role "CanCopyPackages" may have the following rights:
      | add_work_packages          |
      | view_work_packages         |
      | view_view_package_watchers |
    And there is a role "CanAddWatchers"
    And the role "CanAddWatchers" may have the following rights:
      | add_work_packages          |
      | view_work_packages         |
      | view_view_package_watchers |
      | add_work_package_watchers  |
    And there is 1 user with the following:
      | login | ndnd |
    And the user "ndnd" is a "CanCopyPackages" in the project "omicronpersei8"
    And there is 1 user with the following:
      | login | lrrr |
    And the user "lrrr" is a "CanAddWatchers" in the project "omicronpersei8"
    And there are the following issue status:
      | name | is_default |
      | New  | true       |
    And there is a default issuepriority with:
      | name   | Normal |
    And the project "omicronpersei8" has the following types:
      | name | position |
      | Bug  |     1    |
    And the user "lrrr" has 1 issue with the following:
      | subject     | Improve drive  |
      | description | Acquire horn   |
    And the issue "Improve drive" is watched by:
      | lrrr |
      | ndnd |

  Scenario: Watchers shouldn't be copied when the user doesn't have the permission to
    Given I am already logged in as "ndnd"
    When I go to the copy page for the work package "Improve drive"
    Then I should not see "Watchers"
    When I fill in "Subject" with "Improve drive even more"
    And I submit the form by the "Create" button
    Then I should not see "Watchers"
    And the issue "Improve drive even more" should have 0 watchers

  Scenario: Watchers should be copied when the user has the permission to
    Given I am already logged in as "lrrr"
    When I go to the copy page for the work package "Improve drive"
    Then I should see "Watchers" within "p#watchers_form"
    When I fill in "Subject" with "Improve drive even more"
    And I submit the form by the "Create" button
    Then I should see "Watchers (2)"
    And the issue "Improve drive even more" should have 2 watchers