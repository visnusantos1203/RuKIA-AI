module Llm
  module Llama
    class Client
      SUPPORTED_MODELS = %w[ llama3.2 llama3.3].freeze

      def initialize
        @client = Faraday.new(
          url: ollama_url,
          headers: { "Content-Type" => "application/json" }
        )
      end

      def query(model, prompt)
        validate_model!(model)

        params = {
          model: model,
          prompt: prompt,
          stream: false
        }.to_json

        response = @client.post("generate", params)

        JSON.parse(response.body)["response"]
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

      def ollama_url
        ENV.fetch("OLLAMA_URL")
      end

      def ollama_api_key
        ENV.fetch("LLAMA_API_KEY")
      end

      def validate_model!(model)
        raise UnsupportedModelError unless SUPPORTED_MODELS.include?(model)
      end
    end
  end
end
