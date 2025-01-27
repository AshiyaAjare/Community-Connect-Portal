class CreateQueryTags < ActiveRecord::Migration[7.2]
  def change
    create_table :query_tags do |t|
      t.references :query, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :query_tags, [:query_id, :tag_id], unique: true
  end
end
