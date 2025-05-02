# frozen_string_literal: true

class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)

    begin
      document.update(status: :processing)
      document.process_file

      # After successful processing
      document.update(status: :processed)
    rescue => e
      puts "Error sa Job: #{e}"
      document.update(status: :error, is_active: false)
      Rails.logger.error("Error processing document #{document_id}: #{e.message}")
    end
  end
end
