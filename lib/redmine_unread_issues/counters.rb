# frozen_string_literal: true

# Счётчики для верхнего меню: назначено мне / непрочитанные / изменённые.
# Форк: ErmolinAP (сборка как на support.hostco.ru).
module RedmineUnreadIssues
  module Counters
    module_function

    # Возвращает {assigned:, unread:, updated:} для пользователя.
    # assigned - открытые задачи, назначенные на пользователя;
    # unread   - из них те, которые он ни разу не открывал;
    # updated  - назначенные задачи, у которых updated_on позже последнего просмотра.
    def for(user)
      return {assigned: 0, unread: 0, updated: 0} unless user && user.logged?

      visible = Issue.visible(user)
      base = visible.where(assigned_to_id: user.id)

      assigned = base.open.count

      read_ids = ReadIssue.where(user_id: user.id).select(:issue_id)
      unread = base.where.not(id: read_ids).count

      updated = base
                .joins(:read_issues)
                .where(read_issues: {user_id: user.id})
                .where('read_issues.read_at < issues.updated_on')
                .count

      {assigned: assigned, unread: unread, updated: updated}
    end
  end
end
