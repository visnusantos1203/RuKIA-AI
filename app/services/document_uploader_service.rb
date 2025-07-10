# frozen_string_literal: true

class DocumentUploaderService
  def initialize(user:, file:)
    @user = user
    @file = file
  end

  def call
    document = @user.documents.new(
      name: @file.original_filename,
      file_type: @file.content_type,
      status: :processing,
      is_active: true,
      file: @file
    )

    if document.save
      ProcessDocumentJob.perform_later(document.id)
      { success: true, document: document }
    else
      { success: false, errors: document.errors.full_messages }
    end
  end
end
