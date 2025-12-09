module RedmineUnreadIssues
  module IssuesHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :issue_history_tabs_without_read_issue, :issue_history_tabs
        alias_method :issue_history_tabs, :issue_history_tabs_with_read_issue
      end
    end

    module InstanceMethods
      def issue_history_tabs_with_read_issue
        tabs = issue_history_tabs_without_read_issue
        if User.current.allowed_to?(:view_read_users, @issue.project) && @issue.read_issues.any?
          tabs << { name: 'read', label: :unread_issues_label_unread, partial: 'issues/unread', locals: { issue: @issue } }
        end
        tabs
      end
    end
  end
end
