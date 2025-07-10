# frozen_string_literal: true

module Api
  module V1
    class DocumentsController < ApplicationController
      before_action :authenticate_user!

      def index
        @documents = Document.all

        render json: @documents, status: :ok
      end

      def create
        result = DocumentUploaderService.new(user: current_user, file: params[:document][:file]).call

        respond_to do |format|
          if result[:success]
            format.json { render json: { success: "Document uploaded and processing" }, status: :ok }
          else
            Rails.logger.error("Document upload failed: #{result[:errors].join(', ')}")
            format.json { render json: { error: "Document upload failed" }, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @document = current_user.documents.find(params[:id])

        if @document.destroy
          render json: { success: "Document deleted successfully" }, status: :ok
        else
          Rails.logger.error("Document deletion failed: #{@document.errors.full_messages.join(', ')}")
          render json: { error: "Document deletion failed" }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Document not found: #{e.message}")
        render json: { error: "Document not found" }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error deleting document: #{e.message}")
        render json: { error: "Unexpected error deleting document" }, status: :internal_server_error
      end


      private

      def document_params
        params.require(:document).permit(:title, :content, :file)
      end
    end
  end
end
