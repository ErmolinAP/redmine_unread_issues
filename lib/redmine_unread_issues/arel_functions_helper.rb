# This file is a part of RedmineX Assets plugin
# for Redmine
#
# Copyright 2020-2022 RedmineX. All Rights Reserved.
# https://www.redmine-x.com
#
# Licensed under GPL v2 (http://www.gnu.org/licenses/gpl-2.0.html)
# Created by Ondřej Svejkovský

module RedmineUnreadIssues
  module ArelFunctionsHelper
    # Prepares Arel relation with call of CONCAT db function
    # @param [array of string] *strings - strings to concatenate
    # @return [Arel::Nodes::NamedFunction] - Arel node with CONCAT function
    def self.concat(*strings)
      Arel::Nodes::NamedFunction.new(
        'CONCAT', strings.map { |str| Arel::Nodes.build_quoted(str) }
      )
    end

    # Prepares Arel relation with call of LEFT db function
    # @param [string] string - string to get characters from
    # @param [integer] length - number of chars returned from the left side of the string
    # @return [Arel::Nodes::NamedFunction] - Arel node with LEFT function
    def self.left(string, length)
      Arel::Nodes::NamedFunction.new(
        'LEFT', [string, length]
      )
    end

    # Prepares Arel relation with call of TRIM db function
    # @param [string] string - string to trim
    # @return [Arel::Nodes::NamedFunction] - Arel node with TRIM function
    def self.trim(string)
      Arel::Nodes::NamedFunction.new(
        'TRIM', [string]
      )
    end

    # Prepares Arel relation with db comparison condition
    # @param [string] operator - operator of condition, e.g. '>' or '@>' etc.'
    # @param [any type] left - anything which can be on the left side of comparison
    # @param [any type] right - anything which can be on the right side of comparison
    # @return [Arel::Nodes::NamedFunction] - Arel node with comparison condition
    def self.condition(left, operator, right)
      Arel::Nodes::InfixOperation.new(
        operator, left, right
      )
    end

    # Prepares Arel relation with db comparison condition
    # @param [Boolean] condition - condition to verify
    # @param [any type] then_do - what should be done if condition is true
    # @param [any type] else_do - what should be done if condition is false
    # @return [Arel::Nodes::Case] - Arel node with CASE clause
    def self.if(condition, then_do, else_do)
      Arel::Nodes::Case.new().when(condition).then(then_do).else(else_do)
    end

    # Prepares Arel relation with call of CAST db function
    # @param [Arel::Nodes] value_to_cast - Arel relation which should be cast to other type
    # @param [string] cast_type - value type, e.g. 'INTEGER' or 'TEXT[]' etc.
    # @return [Arel::Nodes::NamedFunction] - Arel node with CAST function
    def self.cast(value_to_cast, cast_type)
      Arel::Nodes::NamedFunction.new(
        'CAST', [value_to_cast.as(cast_type)]
      )
    end

    # Prepares Arel relation which divides left operand by the right operand
    # @param [any type] left - anything which can be on the left side of division
    # @param [any type] right - anything which can be on the right side of division
    # @return [Arel::Nodes::NamedFunction] - Arel node with division
    def self.division(left, right)
      Arel::Nodes::Division.new(
        left,
        right
      )
    end

    # Prepares Arel IN condition
    # @param [any type] left - anything which can be on the left side of IN clause
    # @param [any type] right - anything which can be on the right side of IN clause
    # @return [Arel::Nodes::In] - Arel node with IN clause
    def self.in(left, right)
      Arel::Nodes::In.new(
        left,
        right
      )
    end

    # Prepares Arel MAX condition
    # @param [any type] values - anything which can be in the max aggregate function
    # @return [Arel::Nodes::NamedFunction] - Arel node with MAX function
    def self.max(values)
      Arel::Nodes::Max.new(
        values
      )
    end
  end

end