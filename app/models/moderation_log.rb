class ModerationLog < ApplicationRecord
    belongs_to :query
    belongs_to :response, optional:true

    enum action: {no_action: 0, soft_delete: 1, approve: 2, flag: 3}
end
