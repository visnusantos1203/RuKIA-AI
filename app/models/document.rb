# frozen_string_literal: true

class Document < ApplicationRecord
  include Embeddable

  belongs_to :user

  has_one_attached :file
  has_many :chunks, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum status: {
    uploaded: 0,
    processing: 1,
    processed: 2,
    error: 3
  }

  # has_neighbors :embedding

  # before_validation :generate_embedding, if: :content_changed?

  validates :name, :file_type, presence: true

  def process_file
    text = extract_text_from_file.to_s.strip

    if text.empty?
      Rails.logger.warn "No text extracted from file."
      return
    end

    create_semantic_chunks(text)
  end

  private

  def create_semantic_chunks(text)
    chunking_service = SemanticChunkingService.new
    semantic_chunks = chunking_service.chunk_text(text)

    semantic_chunks.each_with_index do |chunk_data, index|
      content = chunk_data[:content].to_s.strip

      next if content.empty?

      Rails.logger.info "Chunk data: #{content}"
      # Placeholder for actual token count logic
      chunk_data_params = {
        content: content,
        chunk_index: index,
        document_id: id,
        embedding: generate_embedding(content),
        token_count: 123,
        metadata: {
          context: chunk_data[:context].to_s,
          position: "#{index + 1} of #{semantic_chunks.length}"
        }
      }

      chunk = Chunk.new(chunk_data_params)
      chunk.save!
    end
  end


  def extract_text_from_file
    raise "File not attached" unless file.attached?

    extraction_service = FileExtractionService.new(file)

    case file.content_type
    when "application/pdf"
      # puts "Extract PDF: #{extraction_service.extract_pdf_text}"
      extraction_service.extract_pdf_text
    when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      extraction_service.extract_docx_text
    when "text/plain"
      file.download.force_encoding("UTF-8")
    else
      raise "Unsupported file type"
    end
  rescue => e
    puts "Error extracting text: #{e.message}"
  end

  def generate_embedding(content)
    return unless content.present?

    embedding_service = EmbeddingService.new(content)

    embedding_service.call
  end
end
