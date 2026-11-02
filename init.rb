Redmine::Plugin.register :redmine_unread_issues do
  name 'Redmine Evolution Unread Issue plugin'
  description 'This is a plugin for Redmine'
  author 'Roman Kharchenko'
  description 'This is a plugin for Redmine'
  url 'https://redmine-evolution.com/our-plugins/'
  author_url 'mailto:onlycssclub@gmail.com'
  version '1.2.0'

  settings :default => {
    'redmine_unread_issues_date' => 'distance_of_time_in_words',
  }, partial: 'redmine_unread_issues/settings'

  project_module :issue_tracking do
    permission :view_read_users, { }
  end
end

require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/arel_functions_helper'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/issue_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/agile_board_helper_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/issue_query_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/issues_controller_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/queries_controller_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/user_patch'
require_dependency File.dirname(__FILE__) + '/lib/redmine_unread_issues/counters'

unless Issue.included_modules.include?(RedmineUnreadIssues::IssuePatch)
  Issue.send(:include, RedmineUnreadIssues::IssuePatch)
end

unless IssueQuery.included_modules.include?(RedmineUnreadIssues::IssueQueryPatch)
  IssueQuery.send(:include, RedmineUnreadIssues::IssueQueryPatch)
end

def file_exist?(path)
  File.respond_to?(:exist?) ? File.exist?(path) : File.exists?(path)
end

if file_exist?(Rails.root.join('plugins/redmine_agile'))
  unless AgileBoardsHelper.included_modules.include?(RedmineUnreadIssues::AgileBoardHelperPatch)
    AgileBoardsHelper.send(:include, RedmineUnreadIssues::AgileBoardHelperPatch)
  end
end

if file_exist?(Rails.root.join('plugins/redmine_x_gantt'))
  unless RedmineXGantt::Helpers::DataHelper.included_modules.include?(RedmineUnreadIssues::DataHelperPatch)
    RedmineXGantt::Helpers::DataHelper.send(:include, RedmineUnreadIssues::DataHelperPatch)
  end
end


if file_exist?(Rails.root.join('plugins/redmine_x_agile_my_page'))
  unless KanbanDataHelper.included_modules.include?(RedmineUnreadIssues::KanbanDataHelperPatch)
    KanbanDataHelper.send(:include, RedmineUnreadIssues::KanbanDataHelperPatch)
  end
end


unless IssuesController.included_modules.include?(RedmineUnreadIssues::IssuesControllerPatch)
  IssuesController.send(:include, RedmineUnreadIssues::IssuesControllerPatch)
end

unless IssuesHelper.included_modules.include?(RedmineUnreadIssues::IssuesHelperPatch)
  IssuesHelper.send(:include, RedmineUnreadIssues::IssuesHelperPatch)
end
unless QueriesController.included_modules.include?(RedmineUnreadIssues::QueriesControllerPatch)
  QueriesController.send(:include, RedmineUnreadIssues::QueriesControllerPatch)
end
unless User.included_modules.include?(RedmineUnreadIssues::UserPatch)
  User.send(:include, RedmineUnreadIssues::UserPatch)
end

module RedmineUnreadIssues
  module HooksViews
    class Hooks < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head, :partial => "layouts/redmine_unread_issues/view_layouts_base_html_head"
      render_on :view_layouts_base_body_bottom, :partial => "layouts/redmine_unread_issues/view_layouts_base_body_bottom"
    end
  end
end

