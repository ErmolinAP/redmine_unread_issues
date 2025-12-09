class CreateReadIssues < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
	def change
	    create_table :read_issues do |t|
	    	t.references :user
	    	t.references :issue
		    t.datetime :read_at
		    t.timestamps
			end

			add_index :read_issues, [:user_id], unique: false
			add_index :read_issues, [:issue_id], unique: false
			add_index :read_issues, [:user_id, :issue_id], unique: true
	end
end
