class ModerationLog < ApplicationRecord
    belongs_to :query, optional:true
    belongs_to :response, optional:true

    enum action: {no_action: 0, soft_delete: 1, approve: 2, flag: 3}

end


# class Response < ApplicationRecord
#     has_many :moderation_logs, dependent: :destroy
  
#     after_update :log_moderation_action, if: -> { saved_change_to_flagged? || saved_change_to_deleted? }
#     before_destroy :log_deletion_action
  
#     private
  
#     def log_moderation_action
#       if flagged?
#         ModerationLog.create(response_id: id, action: :flagged)
#       elsif deleted?
#         ModerationLog.create(response_id: id, action: :deleted)
#       end
#     end
  
#     def log_deletion_action
#       ModerationLog.create(response_id: id, action: :deleted)
#     end
#   end
  