module RedmineUnreadIssues
  module IssuePatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :read_issues, dependent: :delete_all

        alias_method :css_classes_without_read_issue, :css_classes
        alias_method :css_classes, :css_classes_with_read_issue

        has_one :user_read_issue, -> { where user_id: User.current.id }, class_name: 'ReadIssue', foreign_key: 'issue_id'
        has_one :user_read_list, -> { where "#{ReadIssue.table_name}.user_id = #{Issue.table_name}.assigned_to_id" }, class_name: 'ReadIssue', foreign_key: 'issue_id'

        after_save :create_read_issue

      end
    end

    module InstanceMethods
      def css_classes_with_read_issue(user = User.current)
        s = css_classes_without_read_issue(user)

        s << read_issue_class
      end

      def read_issue_unread
        is_unread? ? 1 : 0
      end

      def read_issue_updated
        user_read_issue.try(:read_at)
      end

      def read_issue_class
        return ' unread' if (self.is_unread?)
        return ' updated' if (self.is_updated?)

        ' read'
      end

      def is_unread?
        user_read_issue.nil?
      end

      def is_updated?
        return false if user_read_issue.nil?
        user_read_issue.read_at && user_read_issue.read_at < updated_on
      end

      def create_read_issue
        issue_read         = ReadIssue.where(user_id: User.current.id, issue_id: self.id).first_or_initialize
        issue_read.read_at = Time.now
        issue_read.save unless User.current.anonymous?
      rescue ActiveRecord::RecordNotUnique
        issue_read = IssueRead.where(user_id: User.current.id, issue_id: self.id).first
        if issue_read.present?
          issue_read.read_at = Time.now
          issue_read.save unless User.current.anonymous?
        end
        # nothing

      end

    end
  end
end
