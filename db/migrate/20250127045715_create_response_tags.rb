class CreateResponseTags < ActiveRecord::Migration[7.2]
  def change
    create_table :response_tags do |t|
      t.references :response, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.timestamps
    end
    add_index :response_tags, [:response_id, :tag_id], unique: true
  end
end
