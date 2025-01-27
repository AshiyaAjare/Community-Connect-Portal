class CreateResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :responses do |t|
      t.references :user, null:false, foreign_key:true
      t.references :query, null:false, foreign_key:true
      t.text :content
      t.integer :upvotes, default:0
      t.integer :downvotes, default:0
      t.integer :likes, default:0
      t.boolean :approval, default: false
      t.boolean :flagged, default: false
      t.timestamps
    end
  end
end
