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

describe Allowance::Condition::UsersMemberships do

  include Spec::Allowance::Condition::AllowsConcatenation

  nil_options false

  let(:scope) do
    scope = double('scope', :has_table? => true)

    scope.instance_eval do
      def arel_table(model)
        case model.to_s
        when User.to_s
          User.arel_table
        when Member.to_s
          Member.arel_table
        end
      end
    end

    scope
  end

  let(:klass) { Allowance::Condition::UsersMemberships }
  let(:instance) { klass.new(scope) }
  let(:users_table) { User.arel_table }
  let(:members_table) { Member.arel_table }
  let(:non_nil_options) { {} }
  let(:non_nil_arel) { users_table[:id].eq(members_table[:user_id]) }

  it_should_behave_like "allows concatenation"
  it_should_behave_like "requires models", User, Member

  describe :to_arel do
    it 'limits the returned arel to the provided project if provided' do
      project = double('project', id: 567)

      expected = non_nil_arel.and(members_table[:project_id].eq(project.id)).to_sql

      expect(instance.to_arel(project: project).to_sql).to eql(expected)
    end
  end
end
