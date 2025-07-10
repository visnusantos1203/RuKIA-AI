# frozen_string_literal: true

module Api
  module V1
    class ChatsController < ApplicationController
      before_action :authenticate_user!,
                    :set_question,
                    :set_document,
                    :set_persona, only: [ :chat ]

      after_action :record_llm_response, only: [ :chat ]

      attr_accessor :question, :document, :persona, :message

      def index
        # This will render the chat interface
      end

      def chat
        validate_question!
        record_question

        @response = process_retrieval_and_generation

        respond_to do |format|
          format.json { render json: @response }
        end
      rescue AIAssistant::Errors::Base => e
        handle_ai_error(e)
      rescue StandardError => e
        handle_general_error(e)
      end

      private

      def set_question
        @question = params[:question]
      end

      def set_document
        @document = Document.find_by(id: params[:document_id])

        raise ActiveRecord::RecordNotFound, "Document not found" unless document
      end

      def set_persona
        @persona = params[:persona]&.to_sym || :professional
      end

      def record_question
       @message = Message.create!(
          body: question,
          document: document,
        )
      end

      def record_llm_response
        LlmResponse.create!(
          body: @response[:answer],
          persona: @response[:persona],
          source: @response[:source],
          message: message
        )
      end

      def validate_question!
        raise AIAssistant::Errors::InvalidQueryError, "Question parameter is required" if question.blank?
      end

      def process_retrieval_and_generation
        rag_service = RagService.new(persona: persona, document: document)

        rag_service.call(question)
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
