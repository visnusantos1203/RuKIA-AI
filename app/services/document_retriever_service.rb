# frozen_string_literal: true

class DocumentRetrieverService
  DEFAULT_MAX_CONTEXT_DOCS = 50
  DEFAULT_SIMILARITY_METRIC = "cosine"

  def initialize(question_embedding)
    @question_embedding = question_embedding
  end

  def call
    find_relevant_documents(@question_embedding, DEFAULT_MAX_CONTEXT_DOCS)
  end

  private

  def find_relevant_documents(embedding, max_docs)
    Chunk.nearest_neighbors(
      :embedding,
      embedding,
      distance: DEFAULT_SIMILARITY_METRIC
    ).first(max_docs)
  rescue StandardError => e
    Rails.logger.error("Document retrieval failed: #{e.message}")
    []
  end
end
