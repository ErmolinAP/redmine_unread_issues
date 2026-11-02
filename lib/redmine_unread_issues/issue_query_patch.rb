module RedmineUnreadIssues
  module IssueQueryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        before_destroy :read_issue_validate_settings_before_destroy

        alias_method :issues_without_read_issue, :issues
        alias_method :issues, :issues_with_read_issue

        alias_method :issue_ids_without_read_issue, :issue_ids
        alias_method :issue_ids, :issue_ids_with_read_issue
        
        alias_method :initialize_available_filters_without_read_issue, :initialize_available_filters
        alias_method :initialize_available_filters, :initialize_available_filters_with_read_issue

        alias_method :joins_for_order_statement_without_read_issue, :joins_for_order_statement
        alias_method :joins_for_order_statement, :joins_for_order_statement_with_read_issue

        alias_method :result_count_by_group_without_read_issue, :result_count_by_group
        alias_method :result_count_by_group, :result_count_by_group_with_read_issue

        base.add_available_column(QueryColumn.new(:read_issue_unread, sortable: Proc.new { "case when (#{IssueStatus.table_name}.is_closed = #{connection.quoted_false}) and read_issue_ir.id is null then 1 else 0 end" }, groupable: true, caption: :unread_issues_label_filter_unread))
        base.add_available_column(QueryColumn.new(:read_issue_updated, sortable: Proc.new { "case when (#{IssueStatus.table_name}.is_closed = #{connection.quoted_false}) and read_issue_ir.read_at < #{Issue.table_name}.updated_on then 1 else 0 end" }, groupable: true, caption: :unread_issues_label_filter_updated))
      end
    end

    module InstanceMethods
      def issues_with_read_issue(options={})
        options[:include] ||= [ ]
        unless (options[:include].include?(:user_read_issue))
          options[:include] << :user_read_issue
        end
        issues_without_read_issue(options)
      end

      def issue_ids_with_read_issue(options={})
        options[:include] ||= [ ]
        unless options[:include].include?(:user_read_issue)
          options[:include] << :user_read_issue
        end
        issue_ids_without_read_issue(options)
      end

      def result_count_by_group_with_read_issue
        res = result_count_by_group_without_read_issue
        if self.group_by_column && %w(read_issue_unread read_issue_updated).include?(self.group_by_column.name.to_s)
          res.transform_keys { |key| key.to_i == 1 }
        else
          res
        end
      end

      def sql_for_read_issue_unread_field(field, operator, value)
        return '' if (value == [ ])
        case operator
          when '=', '!'
            if value.size == 1 && (value.include?('1') || value.include?('0'))
              if operator == '!'
                if value.include?('1')
                  value = ['0']
                else
                  value = ['1']
                end
              end
              "case when (
                    NOT EXISTS(
                      SELECT * FROM #{ReadIssue.table_name} read_issue_ir
                        WHERE read_issue_ir.issue_id = #{Issue.table_name}.id and read_issue_ir.user_id = #{User.current.id})
                  ) then 1 else 0 end in (#{value.join(',')})"
            else
              if operator == '!'
                '(1=0)'
              else
                ''
              end
            end
        end
      end

      def sql_for_read_issue_updated_field(field, operator, value)
        return '' if (value == [ ])
        case operator
          when '=', '!'
            if value.size == 1 && (value.include?('1') || value.include?('0'))
              value = (value.include?('1') ? ['0'] : ['1']) if operator == '!'
              compare = value.include?('1') ? '<' : '>'
              # ФИКС форка: в апстриме выражение возвращалось без `in (...)` и
              # PostgreSQL падал с «argument of AND must be type boolean, not type integer»
              " case when ( EXISTS(
                SELECT * FROM #{ReadIssue.table_name} read_issue_ir
                  WHERE read_issue_ir.issue_id = #{Issue.table_name}.id and
                        read_issue_ir.user_id = #{User.current.id} and
                        read_issue_ir.read_at #{compare} #{Issue.table_name}.updated_on)
 ) then 1 else 0 end in (1)"
            else
              if operator == '!'
                '(1=0)'
              else
                ''
              end
            end
        end
      end

      def initialize_available_filters_with_read_issue
        initialize_available_filters_without_read_issue

        add_available_filter('read_issue_unread', type: :list, values: [[l(:general_text_Yes), '1'], [l(:general_text_No), '0']], name: l(:unread_issues_label_filter_unread))
        add_available_filter('read_issue_updated', type: :list, values: [[l(:general_text_Yes), '1'], [l(:general_text_No), '0']], name: l(:unread_issues_label_filter_updated))
      end

      def joins_for_order_statement_with_read_issue(order_options)
        joins = [joins_for_order_statement_without_read_issue(order_options)]

        if order_options
          if order_options.include?(' read_issue_ir.')
            joins << "LEFT JOIN #{ReadIssue.table_name} read_issue_ir ON read_issue_ir.issue_id = #{Issue.table_name}.id and read_issue_ir.user_id = #{User.current.id}"
          end
        end

        joins.compact!
        joins.any? ? joins.join(' ') : nil
      end

      private

      def read_issue_validate_settings_before_destroy
        if (Setting.plugin_redmine_unread_issues || {})['assigned_issues'].to_i == self.id
          self.errors.add(:base, l(:read_issue_error_cant_delete_query_used_in_plugin_settings, link: User.current.admin? ? "<a href='#{Redmine::Utils.relative_url_root}/settings/plugin/unread_issues'>#{l(:read_issue_label_module_settings_custom)}</a>" : l(:read_issue_label_module_settings_custom)).html_safe)
          throw(:abort)
        end
      end

    end
  end
end
