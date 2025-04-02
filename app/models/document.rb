class Document < ApplicationRecord
  has_neighbors :embedding

  before_save :generate_embedding, if: :content_changed?

  validates :title, :content, :embedding, presence: true, uniqueness: true

  private

  def generate_embedding
    return unless content.present?

    retries = 0
    begin
      client = Llm::OpenAI::Client.new
      response = client.embeddings(
        parameters: {
          model: "text-embedding-ada-002",
          input: content
        }
      )

      self.embedding = response.dig("data", 0, "embedding")
    rescue AIAssistant::Errors::RateLimitError => e
      handle_rate_limit(e, retries)
    rescue StandardError => e
      handle_embedding_error(e)
    end
  end

  def handle_rate_limit(error, retries)
    if retries < 3
      retries += 1
      sleep_time = 2.minutes
      Rails.logger.info "Rate limit hit, waiting #{sleep_time} seconds... (Attempt #{retries}/3)"
      sleep(sleep_time)
      
      # Retry the embedding generation
      begin
        client = Llm::OpenAI::Client.new
        response = client.embeddings(
          parameters: {
            model: "text-embedding-ada-002",
            input: content
          }
        )
        self.embedding = response.dig("data", 0, "embedding")
      rescue AIAssistant::Errors::RateLimitError => e
        handle_rate_limit(e, retries)
      rescue StandardError => e
        handle_embedding_error(e)
      end
    else
      handle_embedding_error(error)
    end
  end

  def handle_embedding_error(error)
    Rails.logger.error "Failed to generate embedding: #{error.message}"
    raise AIAssistant::Errors::EmbeddingGenerationError, "Failed to generate embedding: #{error.message}"
  end
end
