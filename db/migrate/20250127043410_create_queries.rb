class CreateQueries < ActiveRecord::Migration[7.2]
  def change
    create_table :queries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :content
      #t.text :tags, array:true, default:[]
      t.timestamps 
    end
  end
end
