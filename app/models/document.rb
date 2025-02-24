class Document < ApplicationRecord
  has_neighbors :embedding

  before_save :generate_embedding, if: :content_changed?

  validates :title, :content, :embedding, presence: true, uniqueness: true

  private

  def generate_embedding
    return unless content.present?

    retries = 0
    begin
      client = OpenAI::Client.new

      puts "client: #{client.inspect}"
      response = client.embeddings(
        parameters: {
          model: "text-embedding-ada-002",
          input: content
        }
      )

      self.embedding = response.dig("data", 0, "embedding")
    rescue => e
      if e.message.include?("429") && retries < 3
        retries += 1
        sleep_time = 2.minutes

        Rails.logger.info "Rate limit hit, waiting #{sleep_time} seconds... (Attempt #{retries}/3)"
        sleep(sleep_time)
        retry
      else
        Rails.logger.error "Failed to generate embedding: #{e.message}"
        raise "Failed to generate embedding: #{e.message}"
      end
    end
  end
end
