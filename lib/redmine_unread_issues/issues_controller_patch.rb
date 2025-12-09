module RedmineUnreadIssues
  module IssuesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do
        before_action :create_or_update_issue_read, only: [:show]
      end
    end

    module InstanceMethods
      private
      def create_or_update_issue_read
        @issue.create_read_issue
      end
    end
  end
end
