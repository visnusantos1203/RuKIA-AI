# frozen_string_literal: true

class FileExtractionService
  def initialize(file)
    @file = file
  end

  def extract_pdf_text
    text = +""

    begin
      reader = PDF::Reader.new(StringIO.new(@file.download))

      return "" if reader.pages.empty?

      reader.pages.each do |page|
        Rails.logger.info "Processing page: #{page.inspect}"
        page_text = page.text.to_s
        Rails.logger.info "Extracted text: #{page_text.inspect}"

        if text.nil?
          Rails.logger.error "Unexpected: 'text' is NIL before concatenation!"
        end

        text << ((page_text + "\n") unless page_text.nil?)
      end
    rescue StandardError => e
      Rails.logger.error "Error extracting PDF text: #{e.message}"
      return nil
    end

    text.force_encoding("UTF-8")
  end


  def extract_docx_text
    doc = Docx::Document.open(@file.download)
    text = doc.paragraphs.map(&:text).join("\n")
    text.force_encoding("UTF-8")
  end
end
