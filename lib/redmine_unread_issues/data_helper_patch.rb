module RedmineUnreadIssues
  module DataHelperPatch

    def self.included(base)
      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method :issue_item_values_without_read_issue, :issue_item_values
        alias_method :issue_item_values, :issue_item_values_with_read_issue

        alias_method :issues_query_without_read_issue, :issues_query
        alias_method :issues_query, :issues_query_with_read_issue

      end
    end

    module InstanceMethods
        AREL = RedmineUnreadIssues::ArelFunctionsHelper

      def issue_subject(issue)
        klass = issue[-1] ? (issue[-2] > issue[-1] ? 'issue_updated ' : 'issue_unread') : 'issue_read'
        "<span class='#{klass}'>#{issue[2]}</span>"
      end

      def issue_item_values_with_read_issue(issues, project_issues_readonly)
        issues_hash = {}
        issues.each { |i| issues_hash[i[0]] = i[1] }
        issues.map do |issue|
          readonly = project_issues_readonly[issue[1]][:all]
          if project_issues_readonly[issue[1]][:all] &&
            !project_issues_readonly[issue[1]][:own] &&
            issue[14] == User.current.id

            readonly = false
          end
          {
            assigned_to:       issue[12],
            author:            issue[13],
            author_id:         issue[14],
            due_date_text:     issue[8],
            end_date:          issue[4].class == Date ? issue[4] + 1 : Date.parse(issue[4]) + 1,
            estimated_hours:   issue[9],
            has_children:      issue[19] > 0 ? true : false,
            id:                issue[0],
            open:              !to_boolean(issue[7]),
            owner_id:          issue[11],
            parent:            issue_item_parent(issue[6], issues_hash, issue[1]),
            priority:          issue[16],
            priority_id:       issue[17],
            priority_position: issue[18],
            progress:          issue[5].to_f,
            project_id:        issue[1],
            readonly:          readonly,
            start_date:        issue[3],
            status:            issue[15],
            text:              issue_subject(issue),
            total_hours:       issue[10],
            type:              "task",
            uid:               issue[0],
            uparent:           "u#{issue[11]}",
            utype:             'task'
          }
        end
      end

      def issues_query_with_read_issue(issues_input, hide_closed_milestones)

        issues          = Issue.arel_table
        issues_children = Issue.arel_table.alias('issues_children')
        time_entries    = TimeEntry.arel_table
        assignees       = User.arel_table.alias('assignees')
        authors         = User.arel_table.alias('authors')
        issue_statuses  = IssueStatus.arel_table
        enumerations    = Enumeration.arel_table
        milestones      = Version.arel_table
        projects        = Project.arel_table

        issues_children_join = issues.join(issues_children, Arel::Nodes::OuterJoin).on(issues_children[:parent_id].eq(issues[:id])).join_sources
        assignees_join       = issues.join(assignees, Arel::Nodes::OuterJoin).on(assignees[:id].eq(issues[:assigned_to_id])).join_sources
        authors_join         = issues.join(authors, Arel::Nodes::OuterJoin).on(authors[:id].eq(issues[:author_id])).join_sources
        issue_statuses_join  = issues.join(issue_statuses).on(issue_statuses[:id].eq(issues[:status_id])).join_sources
        enumerations_join    = issues.join(enumerations).on(enumerations[:id].eq(issues[:priority_id])).join_sources

        issue_id                   = AREL.concat('i', issues[:id])
        start_date_condition_today = AREL.if(issues[:start_date].eq(nil), Date.today, issues[:start_date])
        closed_on_condition        = AREL.if(issues[:closed_on].eq(nil), start_date_condition_today, issues[:closed_on])
        due_date_condition         = AREL.if(issues[:due_date].eq(nil), closed_on_condition, issues[:due_date])
        start_date_condition       = AREL.if(issues[:start_date].eq(nil), due_date_condition, issues[:start_date])

        hide_closed_milestones_condition = issues[:fixed_version_id].eq(nil).or(issues[:fixed_version_id].in(milestones.where(milestones[:id].eq(issues[:fixed_version_id]).and(milestones[:status].not_eq('closed'))).project(milestones[:id])))

        if Redmine::Plugin.installed?(:redmine_x_project_templates)
          project_condition = issues[:project_id].in(projects.where(projects[:id].eq(issues[:project_id]).and(projects[:rx_project_template].eq(false))).project(projects[:id]))
        else
          project_condition = ''
        end

        fixed_version_id_condition = AREL.if(
          issues[:fixed_version_id].eq(nil),
          AREL.cast(issues[:project_id], 'CHAR(20)'),
          AREL.concat('m', issues[:fixed_version_id], '-', issues[:project_id])
        )
        parent_id_condition        = AREL.if(
          issues[:parent_id].eq(nil),
          fixed_version_id_condition,
          AREL.concat('i', issues[:parent_id])
        )

        done_ratio    = AREL.division(issues[:done_ratio], Arel::Nodes::SqlLiteral.new('100.0'))
        due_date_text = AREL.if(
          issues[:due_date].eq(nil),
          Arel::Nodes::SqlLiteral.new('\'N/A\''),
          AREL.cast(issues[:due_date], 'CHAR(30)')
        )

        estimated_hours = AREL.if(
          issues[:estimated_hours].eq(nil),
          Arel::Nodes::SqlLiteral.new('0'),
          issues[:estimated_hours]
        )

        time_entries_condition = time_entries.where(time_entries[:issue_id].eq(issues[:id])).project(time_entries[:hours].sum)
        time_entries_hours     = AREL.if(
          Arel::Nodes::Equality.new(time_entries_condition, nil),
          Arel::Nodes::SqlLiteral.new('0'),
          time_entries_condition
        )

        assignees_id   = AREL.if(
          assignees[:id].eq(nil),
          Arel::Nodes::SqlLiteral.new('-1'),
          assignees[:id]
        )
        assignees_name = AREL.if(
          assignees[:firstname].eq(nil).and(assignees[:lastname].eq(nil)),
          Arel::Nodes::SqlLiteral.new('\'N/A\''),
          AREL.concat(assignees[:firstname], ' ', assignees[:lastname])
        )

        authors_id   = AREL.if(
          authors[:id].eq(nil),
          Arel::Nodes::SqlLiteral.new('-2'),
          authors[:id]
        )
        authors_name = AREL.if(
          authors[:firstname].eq(nil).and(authors[:lastname].eq(nil)),
          Arel::Nodes::SqlLiteral.new('\'N/A\''),
          AREL.concat(authors[:firstname], ' ', authors[:lastname])
        )

        issue_has_children = issues_children[:parent_id].count

        issues_input.joins(assignees_join, authors_join, issue_statuses_join, enumerations_join, issues_children_join)
                    .left_joins(:user_read_issue)
                    .where(project_condition)
                    .where(hide_closed_milestones ? hide_closed_milestones_condition : '')
                    .group(:id, assignees[:id], assignees[:firstname], assignees[:lastname],
                           authors[:id], authors[:firstname], authors[:lastname],
                           issue_statuses[:name], issue_statuses[:is_closed], enumerations[:id],
                           enumerations[:position_name], enumerations[:position], "read_issues.read_at")
                    .pluck(
                      issue_id,
                      issues[:project_id],
                      issues[:subject],
                      start_date_condition,
                      due_date_condition,
                      done_ratio,
                      parent_id_condition,
                      issue_statuses[:is_closed],
                      due_date_text,
                      estimated_hours,
                      time_entries_hours,
                      assignees_id,
                      assignees_name,
                      authors_name,
                      authors_id,
                      issue_statuses[:name],
                      enumerations[:position_name],
                      enumerations[:id],
                      enumerations[:position],
                      issue_has_children,
                      "updated_on",
                      "read_issues.read_at"
                    )
      end
    end
  end
end
