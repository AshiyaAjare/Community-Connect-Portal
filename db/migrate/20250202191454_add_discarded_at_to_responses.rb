class AddDiscardedAtToResponses < ActiveRecord::Migration[7.2]
  def change
    add_column :responses, :discarded_at, :datetime
  end
end
