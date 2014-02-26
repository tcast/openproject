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

class ChiliProject::PrincipalAllowanceEvaluator::NonMember < ChiliProject::PrincipalAllowanceEvaluator::Base

  def applicable?(action, project)
    project.present? && project.is_public?
  end

  def joins(action, project)
    users = User.arel_table
    roles = roles_table
    members = members_table

    permission_matches = matches_condition(action)

    role_id = roles[:id].eq(fallback_role)
    only_natural_users = users[:type].eq(User.to_s)

    role_condition = role_id.and(permission_matches).and(only_natural_users)

    members_join_condition = users[:id].eq(members[:user_id]).and(members[:project_id].eq(project.id))

    agnostic_scope = users.join(roles, Arel::Nodes::OuterJoin)
                          .on(role_condition)
                          .join(members, Arel::Nodes::OuterJoin)
                          .on(members_join_condition)

    User.joins(agnostic_scope.join_sources)
  end

  def condition(condition, action, project)
    members = members_table
    roles = roles_table

    role_has_permission = roles[:id].not_eq(nil)
    no_member = members[:id].eq(nil)

    add_condition = roles.grouping(role_has_permission.and(no_member))

    condition.or(add_condition)
  end

  private

  def fallback_role
    Role.non_member.id
  end

  def roles_table
    Role.arel_table.alias("roles_#{ alias_suffix }")
  end

  def members_table
    Member.arel_table.alias("members_#{ alias_suffix }")
  end

  def member_roles_table
    MemberRole.arel_table.alias("member_#{ alias_suffix }")
  end

  def alias_suffix
    "non_member"
  end

  def matches_condition(action)
    roles = roles_table

    condition = case action
                when Symbol
                  roles['permissions'].matches("%#{action}%")
                when Array
                  condition = Arel::Nodes::Equality.new(1, 0)

                  action.each do |a|
                    condition = condition.or(roles['permissions'].matches("%#{a}%"))
                  end

                  condition
                else
                  raise ArgumentError
                end

    roles.grouping(condition)
  end
end
