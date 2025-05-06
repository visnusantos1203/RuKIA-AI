# frozen_string_literal: true

module Api
  module V1
    class ChatsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [ :chat ]
      def index
        # This will render the chat interface
      end

      def chat
        question = params[:question]
        persona = params[:persona]&.to_sym || :professional

        validate_question!(question)
        process_chat_request(question, persona)
      rescue AIAssistant::Errors::Base => e
        handle_ai_error(e)
      rescue StandardError => e
        handle_general_error(e)
      end

      private

      def validate_question!(question)
        raise AIAssistant::Errors::InvalidQueryError, "Question parameter is required" if question.blank?
      end

      def process_chat_request(question, persona)
        rag_service = RagService.new(persona: persona)
        response = rag_service.query(question)

        respond_to do |format|
          format.json { render json: response }
        end
      end

      def handle_ai_error(error)
        Rails.logger.error("AI Assistant error: #{error.message}")
        respond_to do |format|
          format.json { render json: { error: error.message }, status: :unprocessable_entity }
        end
      end

      def handle_general_error(error)
        Rails.logger.error("Chat error: #{error.message}")
        respond_to do |format|
          format.json { render json: { error: "An unexpected error occurred" }, status: :internal_server_error }
        end
      end
    end
  end
end
