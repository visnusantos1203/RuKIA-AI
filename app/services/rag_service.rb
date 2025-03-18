class RagService
  # Constants for default values
  DEFAULT_MODEL = "gpt-3.5-turbo"
  DEFAULT_EMBEDDING_MODEL = "text-embedding-ada-002"
  DEFAULT_MAX_CONTEXT_DOCS = 3
  DEFAULT_SIMILARITY_METRIC = "cosine"

  def initialize(
    client: Llm::OpenAI::Client.new,
    embedding_model: DEFAULT_EMBEDDING_MODEL,
    model: DEFAULT_MODEL,
    persona: AiAssistant::Personas::Professional.new
  )
    @client = client
    @embedding_model = embedding_model
    @model = model
    @persona = persona
  end

  def query(user_question, max_context_docs: DEFAULT_MAX_CONTEXT_DOCS)
    # Generate embedding for the question
    question_embedding = generate_embedding(user_question)

    # Find relevant documents
    relevant_docs = find_relevant_documents(question_embedding, max_context_docs)

    # Generate response using context and question
    response = generate_response(user_question, relevant_docs)

    # Format and return the result
    {
      question: user_question,
      answer: response,
      sources: relevant_docs.map(&:title)
    }
  end

  def add_document(title:, content:)
    # Create document with embedding
    embedding = generate_embedding(content)
    Document.create!(
      title: title,
      content: content,
      embedding: embedding
    )
  rescue StandardError => e
    Rails.logger.error("Failed to add document: #{e.message}")
    raise DocumentCreationError, "Failed to add document: #{e.message}"
  end

  private

  # Error class for document creation failures
  class DocumentCreationError < StandardError; end

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
    Rails.logger.error("Embedding generation failed: #{e.message}")
    raise "Failed to generate embedding: #{e.message}"
  end

  # Find relevant documents based on embedding similarity
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

  # Generate response using LLM
  def generate_response(question, documents)
    persona_prompt = @persona.system_prompt

    return "No relevant information found." if documents.empty?

    context = build_context(documents)
    prompt = build_prompt(persona_prompt, context, question)

    @client.query(@model, prompt)
  rescue StandardError => e
    Rails.logger.error("Response generation failed: #{e.message}")
    "Sorry, I encountered an error while generating a response."
  end

  # Build context from documents
  def build_context(documents)
    documents.map do |doc|
      "#{doc.title}:\n#{doc.content}"
    end.join("\n\n")
  end

  # Build prompt with context and question
  def build_prompt(persona_prompt, context, question)
    <<~PROMPT
      This is your persona: #{persona_prompt}

      Use the following context to answer the question based on the given persona.
      If you cannot answer the question based on the context, say so.

      Never mention the word "based on the context provided" or anything similar to this phrase in your response.

      Context:
      #{context}

      Question: #{question}
    PROMPT
  end
end
