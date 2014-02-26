#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe User, 'allowed scope' do
  let(:user) { member.principal }
  let(:anonymous) { FactoryGirl.build(:anonymous) }
  let(:project) { FactoryGirl.build(:project, is_public: false) }
  let(:project2) { FactoryGirl.build(:project, is_public: false) }
  let(:role) { FactoryGirl.build(:role) }
  let(:role2) { FactoryGirl.build(:role) }
  let(:anonymous_role) { FactoryGirl.build(:anonymous_role) }
  let(:member) { FactoryGirl.build(:member, :project => project,
                                            :roles => [role]) }

  let(:action) { :the_one }
  let(:other_action) { :another }
  let(:public_action) { :view_project }

  before do
    user.save!
    anonymous.save!
  end

  #todo action with name that is part of another action, check that that will not allow something

  describe "w/ the context being a project
            w/o the project being public
            w/ the user being member in the project
            w/ the role having the necessary permission" do

    before do
      role.permissions << action
      role.save!

      member.save!
    end

    it "should return the user" do
      Allowance.users(permission: action, project: project).should == [user]
    end
  end

 describe "w/ the context being a project
           w/o the project being public
           w/o the user being member in the project
           w/ the user being admin" do

    before do
      user.update_attribute(:admin, true)
    end

    it "should return the user" do
      Allowance.users(permission: action, project: project).should == [user]
    end
  end

 describe "w/ the context being a project
           w/o the project being public
           w/o the user being member in the project
           w/ the user being admin
           w/o allowing the admin to pass" do

    before do
      user.update_attribute(:admin, true)
    end

    it "should return the user" do
      Allowance.users(permission: action, project: project, admin_pass: false).should == []
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/ the user being member in the project
            w/o the role having the necessary permission" do

    before do
      role.save!
      member.save!
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/o the user being member in the project
            w/ the role having the necessary permission" do

    before do
      role.permissions << action
      role.save!
    end

    it "should return the user" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/ the user being member in the project
            w/o asking for a certain permission" do

    before do
      member.save!
    end

    it "should return the user" do
      expect(Allowance.users(project: project)).to eq [user]
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/o the user being member in the project
            w/ the user being member in a different project
            w/ the role having the permission" do

    before do
      role.permissions << action
      role.save!

      member.project = project2
      member.save!
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/ the project being public
            w/o the user being member in the project
            w/ the user being member in a different project
            w/ the role having the permission" do

    before do
      role.permissions << action
      role.save!

      project.is_public = true
      project.save!

      member.project = project2
      member.save!
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/ the project being public
            w/o the user being member in the project
            w/ the non member role having the necessary permission" do

    before do
      project.is_public = true

      non_member = Role.non_member
      non_member.permissions << action
      non_member.save

      project.save!
    end

    it "should return the user" do
      Allowance.users(permission: action, project: project).should == [user]
    end
  end

  describe "w/ the context being a project
            w/ the project being public
            w/o the user being member in the project
            w/ the anonymous role having the necessary permission" do

    before do
      project.is_public = true

      anonymous_role = Role.anonymous
      anonymous_role.permissions << action
      anonymous_role.save

      project.save!
    end

    it "should return the anonymous user" do
      expect(Allowance.users(permission: action, project: project)).to match_array([anonymous])
    end
  end

  describe "w/ the context being a project
            w/ the project being public
            w/o the user being member in the project
            w/ the non member role having another permission" do

    before do
      project.is_public = true

      non_member = Role.non_member
      non_member.permissions << other_action
      non_member.save

      project.save!
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/ the project being private
            w/o the user being member in the project
            w/ the non member role having the permission" do

    before do
      non_member = Role.non_member
      non_member.permissions << action
      non_member.save

      project.save!
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/ the project being public
            w/ the user being member in the project
            w/o the role having the necessary permission
            w/ the non member role having the permission" do

    before do
      role.permissions << other_action
      member.save!

      non_member = Role.non_member
      non_member.permissions << action
      non_member.save
    end

    it "should be empty" do
      Allowance.users(permission: action, project: project).should be_empty
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/ the user being member in the project
            w/o the role having the permission
            w/ the permission being public" do

    before do
      member.save!
    end

    it "should return the user and anonymous" do
      Allowance.users(permission: public_action, project: project).should =~ [user]
    end
  end

  describe "w/ the context being a project
            w/o the project being public
            w/ the user being member in the project
            w/o the role having the permission
            w/ inquiring for multiple permissions
            w/ one permission being public" do

    before do
      member.save!
    end

    it "should return the user and anonymous" do
      Allowance.users(permission: [action, public_action], project: project).should =~ [user]
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/ the role having the necessary permission" do

    before do
      role.permissions << action
      role.save!

      member.save!
    end

    it "should return the user" do
      Allowance.users(permission: action).should == [user]
    end
  end

  describe "w/o the context being a project
            w/o the project being public
            w/o the user being member in the project
            w/ the user being admin" do

    before do
      user.update_attribute(:admin, true)
    end

    it "should return the user" do
      Allowance.users(permission: action).should == [user]
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/o the role having the necessary permission" do

    before do
      member.save!
    end

    it "should be empty" do
      Allowance.users(permission: action).should be_empty
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/o the role having the necessary permission" do

    before do
      member.save!
    end

    it "should be empty" do
      Allowance.users(permission: action).should be_empty
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/o the role having the necessary permission
            w/ non member role having the permission" do

    before do
      role.permissions << other_action
      member.save!

      non_member = Role.non_member
      non_member.permissions << action
      non_member.save
    end

    it "should be be empty" do
      Allowance.users(permission: action).should be_empty
    end
  end

  describe "w/o the context being a project
            w/ an existing project
            w/o the user being member in the project
            w/ non member role having the permission" do

    before do
      FactoryGirl.create(:project)

      non_member = Role.non_member
      non_member.permissions << action
      non_member.save!
    end

    it "should return the user" do
      expect(Allowance.users(permission: action)).to match_array([user])
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/o the role having the necessary permission
            w/ anonymous role having the permission" do

    before do
      role.permissions << other_action
      member.save!

      anonymous_role = Role.anonymous
      anonymous_role.permissions << action
      anonymous_role.save
    end

    it "should be anonymous" do
      Allowance.users(permission: action).should =~ [anonymous]
    end
  end

  describe "w/ the context being a project
            w/ the user being member in the project
            w/ asking for a certain permission
            w/ the permission belonging to a module
            w/o the module being active" do
    let(:permission) do
      Redmine::AccessControl.permissions.find{ |p| p.project_module.present? }
    end

    before do
      project.enabled_module_names = []

      role.permissions << permission.name
      member.save!
    end

    it "should be empty" do
      expect(Allowance.users(project: project, permission: permission.name)).to eq []
    end
  end

  describe "w/ the context being a project
            w/ the user being member in the project
            w/ asking for a certain permission
            w/ the permission belonging to a module
            w/ the module being active" do
    let(:permission) do
      Redmine::AccessControl.permissions.find{ |p| p.project_module.present? }
    end

    before do
      project.enabled_module_names = [permission.project_module]

      role.permissions << permission.name
      member.save!
    end

    it "should return the user" do
      expect(Allowance.users(project: project, permission: permission.name)).to eq [user]
    end
  end

  describe "w/ the context being a project
            w/ the user being member in the project
            w/ asking for a certain permission
            w/ the user having the permission in the project
            w/o the project being active" do
    before do
      role.permissions << action
      member.save!

      project.update_attribute(:status, Project::STATUS_ARCHIVED)
    end

    it "should be empty" do
      expect(Allowance.users(project: project, permission: action)).to eq []
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/ asking for a certain permission
            w/ the permission belonging to a module
            w/o the module being active" do
    let(:permission) do
      Redmine::AccessControl.permissions.find{ |p| p.project_module.present? }
    end

    before do
      project.enabled_module_names = []

      role.permissions << permission.name
      member.save!
    end

    it "should be empty" do
      expect(Allowance.users(permission: permission.name)).to eq []
    end
  end

  describe "w/o the context being a project
            w/ the user being member in a project
            w/ asking for a certain permission
            w/ the permission belonging to a module
            w/ the module being active" do
    let(:permission) do
      Redmine::AccessControl.permissions.find{ |p| p.project_module.present? }
    end

    before do
      project.enabled_module_names = [permission.project_module]

      role.permissions << permission.name
      member.save!
    end

    it "should return the user" do
      expect(Allowance.users(permission: permission.name)).to eq [user]
    end
  end

  describe "w/o the context being a project
            w/ asking for a certain permission
            w/ the user having the permission in a project
            w/o the project being active" do
    before do
      role.permissions << action
      member.save!

      project.update_attribute(:status, Project::STATUS_ARCHIVED)
    end

    it "should be empty" do
      expect(Allowance.users(permission: action)).to eq []
    end
  end

  describe "w/o the context being a project
            w/ asking for a certain permission
            w/ the user having the permission in a project
            w/o the project being active
            w/ the non_member being allowed the permission" do
    before do
      role.permissions << action
      member.save!

      non_member = Role.non_member
      non_member.permissions << action
      non_member.save!

      project.update_attribute(:status, Project::STATUS_ARCHIVED)
    end

    it "should return the user" do
      expect(Allowance.users(permission: action)).to eq [user]
    end
  end
end
