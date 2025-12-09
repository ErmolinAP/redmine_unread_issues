module RedmineUnreadIssues
  module UserPatch
    def self.included(base)
      base.class_eval do
        has_many :read_issues, dependent: :delete_all
        has_many :assigned_issues, class_name: 'Issue' , foreign_key: 'assigned_to_id'
      end
    end
  end
end
