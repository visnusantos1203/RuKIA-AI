# frozen_string_literal: true

class EmbeddingService
  DEFAULT_EMBEDDING_MODEL = "text-embedding-ada-002"

  def initialize(content)
    @content = content
  end

  def call
    generate_embedding
  end

  private

  def generate_embedding
    client = Llm::OpenAI::Client.new
    response = client.embeddings(
      parameters: {
        model: DEFAULT_EMBEDDING_MODEL,
        input: @content
      }
    )

    response.dig("data", 0, "embedding")
  rescue AIAssistant::Errors::RateLimitError => e
    handle_rate_limit(e)
  rescue StandardError => e
    handle_embedding_error(e)
  end

  def handle_rate_limit(error)
    retries = 0
    max_retries = 3
    sleep_time = 2.minutes

    while retries < max_retries
      Rails.logger.info "Rate limit hit, waiting #{sleep_time} seconds... (Attempt #{retries + 1}/#{max_retries})"
      sleep(sleep_time)
      retries += 1

      begin
        generate_embedding
        break
      rescue AIAssistant::Errors::RateLimitError => e
        next if retries < max_retries
        handle_embedding_error(e)
      end
    end
  end

  def handle_embedding_error(error)
    Rails.logger.error "Failed to generate embedding: #{error.message}"
    raise AIAssistant::Errors::EmbeddingGenerationError, "Failed to generate embedding: #{error.message}"
  end
end
