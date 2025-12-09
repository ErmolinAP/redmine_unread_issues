class ReadIssue < ActiveRecord::Base
  #unloadable

  belongs_to :user, optional: true
  belongs_to :issue, optional: true

end
