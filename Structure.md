evo_tag_me/
   |
   ├── app/
   |   |
   |   ├── models/
   |   |   └── read_issue.rb
   |   |
   |   └── views/
   |       |
   |       ├── evo_mentions/
   |       |   └── _unread.html.erb
   |       |
   |       ├── layouts/
   |       |   ├── _view_layouts_base_body_bottom.html.erb
   |       |   └── _view_layouts_base_html_head.html.erb
   |       |
   |       └── _redmine_unread_issues/
   |           └── _settings.html.erb
   │
   ├── assets/
   |   |
   |   └── stylesheets/
   |       └── evo_tag_me.css
   │
   ├── config/
   |   |
   |   ├── locales/
   |   |   ├── de.yml
   |   |   ├── en.yml
   |   |   ├── fr.yml
   |   |   ├── it.yml
   |   |   ├── ko.yml
   |   |   ├── pt.yml
   |   |   ├── ru.yml
   |   |   ├── uk.yml
   |   |   └── zh.yml
   |   |
   |   └── routes.rb
   │
   ├── db/
   |   |
   |   └── migrate/
   |       └── 001_create_read_issues.rb
   │
   ├── lib/
   |   |
   |   └── redmine_unread_issues/
   |       ├── agile_board_helper_patch.rb
   |       ├── arel_functions_helper.rb
   |       ├── data_helper_patch.rb
   |       ├── issue_patch.rb
   |       ├── issue_query_patch.rb
   |       ├── issues_controller_patch.rb
   |       ├── issues_helper_patch.rb
   |       ├── kanban_data_helper_patch.rb
   |       ├── queries_controller_patch.rb
   |       └── user_patch.rb
   |
   ├── test/
   |   └── test_helper.rb
   |
   ├── init.rb
   ├── README.md
   └── Structure.md
