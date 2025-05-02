# frozen_string_literal: true

module Llm
  module OpenAI
    class Client < Llm::BaseClient
      SUPPORTED_MODELS = %w[
        dall-e-2
        dall-e-3
        gpt-3.5-turbo
        gpt-4
        gpt-4-2024-05-13
        gpt-4-mini
      ].freeze

      def embeddings(parameters:)
        @client.embeddings(parameters: parameters)
      rescue StandardError => e
        Rails.logger.error("Embedding generation failed: #{e.message}")
        raise AIAssistant::EmbeddingGenerationError, "Failed to generate embedding: #{e.message}"
      end

      private

      def build_client
        ::OpenAI::Client.new
      end

      def validate_model!(model)
        return if SUPPORTED_MODELS.include?(model)
        raise AIAssistant::ModelNotSupportedError, 
              "Model '#{model}' is not supported. Please use one of: #{SUPPORTED_MODELS.join(', ')}"
      end

      def perform_query(model, prompt)
        response = @client.chat(
          parameters: {
            model: model,
            messages: [{ role: "user", content: prompt }],
            temperature: 0.7
          }
        )
        response.dig("choices", 0, "message", "content")
      end
    end
  end
end 