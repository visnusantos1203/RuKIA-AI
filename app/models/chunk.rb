# frozen_string_literal: true

class Chunk < ApplicationRecord
  include Embeddable

  belongs_to :document
  has_neighbors :embedding

  before_validation :generate_embedding

  validates :content, presence: true

  private

  def generate_embedding
    embedding_service = EmbeddingService.new(content)

    embedding_service.call
  end
end
