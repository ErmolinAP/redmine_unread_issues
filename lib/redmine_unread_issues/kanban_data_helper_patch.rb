module RedmineUnreadIssues
  module KanbanDataHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do

            alias_method :issue_data_without_read_issue, :issue_data
            alias_method :issue_data, :issue_data_with_read_issue

      

      end
    end

    module InstanceMethods
      def issue_subject(issue)
        "<span class='#{issue.read_issue_class}'>#{issue.subject}</span>"
      end

      def issue_data_with_read_issue(query)
        issue_board = query.issue_board
        issues_arr = []
        issue_board.each do |place, issues|
          issues.each do |issue|
            issue_obj = {
              id: issue.id,
              status: place[0],
              text: issue_subject(issue),
              assignee: issue.assigned_to ? assignee_name(issue.assigned_to) : nil,
              assignee_name: issue.assigned_to ? issue.assigned_to.name : nil,
              avatar: assignee_avatar(issue.assigned_to),
              due_date: format_date(issue.due_date),
              tracker: issue.tracker.name,
              priority_color: priority_color(issue)
            }
            issue_obj[:user] = place[1] || 0
            if !query.project && !(query.grouped? && query.group_by_column.name == 'project')
              issue_obj[:project] = project_name(issue.project)
            end
            issues_arr << issue_obj
          end
        end
        issues_arr
      end
    end
  end
end
