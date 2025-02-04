class AddDiscardedAtToTags < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :discarded_at, :datetime
  end
end
