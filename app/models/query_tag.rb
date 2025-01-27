class QueryTag < ApplicationRecord
    belongs_to :query 
    belongs_to :tag
end
