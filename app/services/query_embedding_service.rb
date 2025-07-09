# frozen_string_literal: true

class QueryEmbeddingService
  def initialize(user_question)
    @user_question = user_question
  end

  def call
    generate_embedding
  end

  private

  def generate_embedding
    embedding_service = EmbeddingService.new(@user_question)

    embedding_service.call
  rescue StandardError => e
    raise AIAssistant::Errors::EmbeddingGenerationError, "Failed to generate embedding: #{e.message}"
  end
end
