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

module Spec
  module Allowance
    module Condition
      module AllowsConcatenation
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def nil_options(is = true)
            @nil_options = is
          end

          def has_nil_options?
            @nil_options
          end

          shared_examples "requires models" do |*models|
            describe :to_arel do
              models.each do |model|
                it "fails if no table for the #{model} is defined in the scope" do
                  scope.stub(:has_table?).with(model).and_return(false)

                  expect { instance.to_arel }.to raise_error(::Allowance::Condition::TableMissingInScopeError)
                end
              end
            end
          end

          shared_examples "allows concatenation" do
            let(:test_condition) do
              Class.new do
                def to_arel(options = nil)
                  ::Arel::Nodes::Equality.new(1, 1)
                end
              end.new
            end

            let(:nil_test_condition) do
              Class.new do
                def to_arel(options = nil)
                  nil
                end
              end.new
            end

            describe :and do
              it 'should return itself' do
                instance.and(test_condition).should == instance
              end
            end

            describe :or do
              it 'should return itself' do
                instance.or(test_condition).should == instance
              end
            end

            describe :to_arel do
              it 'returns an arel statement' do
                expect(instance.to_arel(non_nil_options).to_sql).to eq non_nil_arel.to_sql
              end

              if has_nil_options?
                it 'returns an arel statement if nothing is passed' do
                  expect(instance.to_arel.to_sql).to eq non_nil_arel.to_sql
                end

                it 'returns nil if admin_pass is false' do
                  expect(instance.to_arel(nil_options)).to be_nil
                end
              end

              it 'returns the ored conditions' do
                instance.or(test_condition)

                expected = (non_nil_arel.or(test_condition.to_arel)).to_sql

                expect(instance.to_arel(non_nil_options).to_sql).to eq expected
              end

              it 'returns the anded conditions' do
                instance.and(test_condition)

                expected = (non_nil_arel.and(test_condition.to_arel)).to_sql

                expect(instance.to_arel(non_nil_options).to_sql).to eq expected
              end

              it 'returns only the original condition if the anded condition is nil' do
                instance.and(nil_test_condition)

                expected = non_nil_arel.to_sql

                expect(instance.to_arel(non_nil_options).to_sql).to eq expected
              end

              it 'returns only the original condition if the ored condition is nil' do
                instance.or(nil_test_condition)

                expected = non_nil_arel.to_sql

                expect(instance.to_arel(non_nil_options).to_sql).to eq expected
              end

              if has_nil_options?
                it 'returns only the anded condition if the condition returns nil' do
                  instance.and(test_condition)

                  expected = (test_condition.to_arel).to_sql

                  expect(instance.to_arel(nil_options).to_sql).to eq expected
                end

                it 'returns only the ored condition if the condition returns nil' do
                  instance.or(test_condition)

                  expected = (test_condition.to_arel).to_sql

                  expect(instance.to_arel(nil_options).to_sql).to eq expected
                end
              end
            end
          end
        end
      end
    end
  end
end
