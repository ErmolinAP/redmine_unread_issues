module RedmineUnreadIssues
  module AgileBoardHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method :agile_color_class_without_read_issue, :agile_color_class
        alias_method :agile_color_class, :agile_color_class_with_read_issue


      end
    end

    module InstanceMethods
      def agile_color_class_with_read_issue(issue, options={})
        s = Array.wrap(agile_color_class_without_read_issue(issue, options))

        s << ' unread' if (issue.is_unread?)
        s << ' updated' if (issue.is_updated?)
        s.join(' ')
      end

    end
  end
end
