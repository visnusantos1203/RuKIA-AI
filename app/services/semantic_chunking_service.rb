# frozen_string_literal: true

class SemanticChunkingService
  ## TODO: Find a better implementation for this. Leverage NLP if possible
  def chunk_text(text)
    paragraphs = text.split(/\n\n+/).compact.map(&:strip).reject(&:empty?)
    chunks = []

    paragraphs.each_with_index do |paragraph, i|
      context = i > 0 ? paragraphs[i-1].to_s[-100..].to_s : ""
      context += i < paragraphs.length - 1 ? paragraphs[i+1].to_s[0..100].to_s : ""

      chunks << { content: paragraph, context: context }
    end

    chunks
  end

  private

  def get_context_from_prev_paragraph(paragraph, i)
    i > 0 ? paragraphs[i-1].to_s[-100..].to_s : ""
  end

  def get_context_from_next_paragraph(paragraph, i)
    i < paragraphs.length - 1 ? paragraphs[i+1].to_s[0..100].to_s : ""
  end
end
