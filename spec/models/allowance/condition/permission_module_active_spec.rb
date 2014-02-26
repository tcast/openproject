#-- encoding: UTF-8
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

require_relative 'shared/allows_concatenation'

describe Allowance::Condition::PermissionsModuleActive do

  include Spec::Allowance::Condition::AllowsConcatenation

  nil_options true

  let(:scope) do
    scope = double('scope', :has_table? => true)

    scope.instance_eval do
      def arel_table(model)
        if [EnabledModule].include?(model)
          model.arel_table
        end
      end
    end

    scope
  end

  let(:klass) { Allowance::Condition::PermissionsModuleActive }
  let(:instance) { klass.new(scope) }
  let(:enabled_module_table) { EnabledModule.arel_table }
  let(:nil_options) { {} }
  let(:non_nil_options) { { permission: permission_with_module } }
  let(:permission_with_module) { Redmine::AccessControl.permissions.find { |p| p.project_module.present? }.name }
  let(:permission_without_module) { Redmine::AccessControl.permissions.find { |p| p.project_module.nil? }.name }
  let(:non_nil_arel) do
    module_name = Redmine::AccessControl.permission(permission_with_module).project_module

    enabled_module_table[:name].eq(module_name)
  end

  it_should_behave_like "allows concatenation"
  it_should_behave_like "requires models", EnabledModule

  describe :to_arel do
    it 'returns arel checking for module enabled when permission does belong to a project module' do
      expect(instance.to_arel(permission: permission_with_module).to_sql).to eq(non_nil_arel.to_sql)
    end

    it 'returns nil when permission does belong to a project module' do
      expect(instance.to_arel(permission: permission_without_module)).to be_nil
    end

    it 'returns nil when permission is nil' do
      expect(instance.to_arel(permission: nil)).to be_nil
    end
  end
end
