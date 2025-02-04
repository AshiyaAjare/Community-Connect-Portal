class AddDiscardedAtToQueries < ActiveRecord::Migration[7.2]
  def change
    add_column :queries, :discarded_at, :datetime
  end
end
