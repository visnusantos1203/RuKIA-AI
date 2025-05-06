# frozen_string_literal: true

class SemanticChunkingService
  ## TODO: Find a better implementation for this. Leverage NLP if possible

  MAX_CHUNK_SIZE = 1000
  OVERLAP_SIZE = 100

  def chunk_text(text)
    # Split into logical sections (paragraphs, headers, lists)
    sections = extract_sections(text)
    chunks = []
    current_chunk = ""
    current_chunk_sections = []

    sections.each do |section|
      # If adding this section would exceed MAX_CHUNK_SIZE, finalize current chunk
      if (current_chunk + section).length > MAX_CHUNK_SIZE && !current_chunk.empty?
        # Create chunk with its content and metadata
        chunks << create_chunk(current_chunk, current_chunk_sections)

        # Start new chunk with overlap from previous chunk
        overlap = current_chunk[-OVERLAP_SIZE..]
        current_chunk = overlap + section
        current_chunk_sections = [ current_chunk_sections.last, section ]
      else
        # Add section to current chunk
        current_chunk += section
        current_chunk_sections << section
      end
    end

    # Add the last chunk if not empty
    chunks << create_chunk(current_chunk, current_chunk_sections) unless current_chunk.empty?
    chunks
  end

  private

  def extract_sections(text)
    sections = []

    # Handle headers, lists, paragraphs as separate sections
    text.split(/(?=^#)|(?=^\s*\d+\.)|(?=^\s*\*)|(?=^\s*-)|(?=\n\n)/).each do |section|
      sections << section.strip
    end

    sections.reject(&:empty?)
  end

  def create_chunk(content, sections)
    normalize = ->(text) { text&.gsub(/\s+/, " ") }

    {
      content: normalize.call(content),
      context: {
        preceding_content: normalize.call(sections.first),
        following_content: normalize.call(sections.last),
        section_count: sections.length || 0
      }
    }
  end
end
