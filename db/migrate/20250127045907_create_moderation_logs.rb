class CreateModerationLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :moderation_logs do |t|
      t.references :query, null:true, foreign_key:true
      t.references :response, null:true, foreign_key:true
      t.integer :action, default:0, null:false
      t.timestamps
    end
  end
end
