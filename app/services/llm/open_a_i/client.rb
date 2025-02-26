module Llm
  module OpenAI
    class Client
      SUPPORTED_MODELS = %w[
        dall-e-2
        dall-e-3
        gpt-3.5-turbo
        gpt-4o
        gpt-4o-2024-05-13
        gpt-4o-mini
        ].freeze

      def initialize
        @client = ::OpenAI::Client.new
      end

      def embeddings(parameters:)
        begin
          @client.embeddings(parameters: parameters)
        rescue StandardError => e
          Rails.logger.error("Embedding generation failed: #{e.message}")
          { "data" => [ { "embedding" => [] } ] }
        end
      end

      def query(model, prompt)
        validate_model!(model)

        response = @client.chat(
          parameters: {
            model: model,
            messages: [ { role: "user", content: prompt } ],
            temperature: 0.7
          }
        )

        response.dig("choices", 0, "message", "content")
      rescue UnsupportedModelError => e
        { error: e.message, status: e.status }
      rescue Faraday::ConnectionFailed => e
        { error: "Connection failed: #{e.message}", status: :service_unavailable }
      rescue Faraday::TimeoutError => e
        { error: "Request timed out: #{e.message}", status: :request_timeout }
      rescue StandardError => e
        { error: "An unexpected error occurred: #{e.message}", status: :internal_server_error }
      end

      private

      class UnsupportedModelError < StandardError
        def code
          :bad_request
        end

        def message
          "We don't currently support that model. Please try one of the following: #{SUPPORTED_MODELS.join(', ')}"
        end

        def status
          400
        end
      end

      def validate_model!(model)
        raise UnsupportedModelError unless SUPPORTED_MODELS.include?(model)
      end
    end
  end
end
