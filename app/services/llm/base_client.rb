# frozen_string_literal: true

module Llm
  class BaseClient
    def initialize
      @client = build_client
    end

    def query(model, prompt)
      validate_model!(model)
      perform_query(model, prompt)
    rescue StandardError => e
      handle_error(e)
    end

    private

    def build_client
      raise NotImplementedError, "#{self.class} must implement build_client"
    end

    def validate_model!(model)
      raise NotImplementedError, "#{self.class} must implement validate_model!"
    end

    def perform_query(model, prompt)
      raise NotImplementedError, "#{self.class} must implement perform_query"
    end

    def handle_error(error)
      case error
      when Faraday::ConnectionFailed
        raise AIAssistant::ConnectionError, "Connection failed: #{error.message}"
      when Faraday::TimeoutError
        raise AIAssistant::TimeoutError, "Request timed out: #{error.message}"
      else
        raise AIAssistant::LLMError, "An unexpected error occurred: #{error.message}"
      end
    end
  end
end 