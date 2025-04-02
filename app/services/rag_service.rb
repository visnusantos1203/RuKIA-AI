class RagService
  # Constants for default values
  DEFAULT_MODEL = "gpt-3.5-turbo"
  DEFAULT_EMBEDDING_MODEL = "text-embedding-ada-002"
  DEFAULT_MAX_CONTEXT_DOCS = 3
  DEFAULT_SIMILARITY_METRIC = "cosine"
  DEFAULT_PERSONA = :professional

  def initialize(
    client: Llm::OpenAI::Client.new,
    embedding_model: DEFAULT_EMBEDDING_MODEL,
    model: DEFAULT_MODEL,
    persona: DEFAULT_PERSONA
  )
    @client = client
    @embedding_model = embedding_model
    @model = model
    @persona = AIAssistant::PersonaRegistry.find(persona)
  end

  def query(user_question, max_context_docs: DEFAULT_MAX_CONTEXT_DOCS)
    question_embedding = generate_embedding(user_question)
    relevant_docs = find_relevant_documents(question_embedding, max_context_docs)
    response = generate_response(user_question, relevant_docs)

    build_response(user_question, response, relevant_docs)
  rescue StandardError => e
    handle_query_error(e)
  end

  def add_document(title:, content:)
    validate_document!(title, content)
    
    embedding = generate_embedding(content)
    Document.create!(
      title: title,
      content: content,
      embedding: embedding
    )
  rescue StandardError => e
    handle_document_error(e)
  end

  private

  def validate_document!(title, content)
    raise AIAssistant::Errors::InvalidDocumentError, "Title and content cannot be blank" if title.blank? || content.blank?
  end

  def generate_embedding(text)
    response = OpenAI::Client.new(
      access_token: ENV.fetch("OPENAI_API_KEY", nil),
      uri_base: "https://api.openai.com",
      request_timeout: 240
    ).embeddings(
      parameters: {
        model: @embedding_model,
        input: text
      }
    )
    response.dig("data", 0, "embedding")
  rescue StandardError => e
    raise AIAssistant::Errors::EmbeddingGenerationError, "Failed to generate embedding: #{e.message}"
  end

  def find_relevant_documents(embedding, max_docs)
    Document.nearest_neighbors(
      :embedding,
      embedding,
      distance: DEFAULT_SIMILARITY_METRIC
    ).first(max_docs)
  rescue StandardError => e
    Rails.logger.error("Document retrieval failed: #{e.message}")
    []
  end

  def generate_response(question, documents)
    return "No relevant information found." if documents.empty?

    context = build_context(documents)
    prompt = build_prompt(context, question)

    @client.query(@model, prompt)
  rescue StandardError => e
    raise AIAssistant::Errors::QueryProcessingError, "Failed to generate response: #{e.message}"
  end

  def build_context(documents)
    documents.map do |doc|
      "#{doc.title}:\n#{doc.content}"
    end.join("\n\n")
  end

  def build_prompt(context, question)
    <<~PROMPT
      #{@persona.system_prompt}

      Use the following context to answer the question based on the given persona.
      If you cannot answer the question based on the context, say so.

      Never mention the word "based on the context provided" or anything similar to this phrase in your response.

      Context:
      #{context}

      Question: #{question}
    PROMPT
  end

  def build_response(question, answer, sources)
    {
      question: question,
      answer: answer,
      sources: sources.map(&:title),
      persona: @persona.name
    }
  end

  def handle_query_error(error)
    Rails.logger.error("Query failed: #{error.message}")
    raise AIAssistant::Errors::QueryError, "Failed to process query: #{error.message}"
  end

  def handle_document_error(error)
    Rails.logger.error("Failed to add document: #{error.message}")
    raise AIAssistant::Errors::DocumentCreationError, "Failed to add document: #{error.message}"
  end
end
