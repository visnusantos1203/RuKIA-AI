# frozen_string_literal: true

class DocumentRetrieverTool < ApplicationTool
  description "Retrieve document"

  arguments do
    required(:name).filled(:string).description("Title of the document to retrieve")
    # required(:file_type).filled(:string).description("Type of the document")
  end

  def call(name:)
    document = Document.where("name ILIKE ?", "%#{name}%").first

    puts document.inspect

    if document
      {
        name: document.name,
        description: document.description,
        status: document.status
      }
    else
      raise AIAssistant::Errors::DocumentNotFoundError, "Document with file_name '#{name}' not found"
    end
  end
end
