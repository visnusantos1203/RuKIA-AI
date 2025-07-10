# frozen_string_literal: true

class Message < ApplicationRecord
  include Embeddable

  belongs_to :document
  has_neighbors :embedding

  has_many :llm_responses, dependent: :destroy

  before_validation :generate_embedding

  validates :body, presence: true

  private

  # check if this can be done in background job
  # this might be too slow for real-time chat
  def generate_embedding
    embedding_service = EmbeddingService.new(body)

    self.embedding = embedding_service.call
  end
end
