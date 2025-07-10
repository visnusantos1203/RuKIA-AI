class LlmResponse < ApplicationRecord
  belongs_to :message

  validates :body, presence: true
end
