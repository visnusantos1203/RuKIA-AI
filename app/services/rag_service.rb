# frozen_string_literal: true

class RagService
  DEFAULT_MODEL = "gpt-3.5-turbo"
  DEFAULT_PERSONA = :professional

  def initialize(
    client: Llm::OpenAI::Client.new,
    model: DEFAULT_MODEL,
    persona: DEFAULT_PERSONA
  )
    @client = client
    @model = model
    @persona = AIAssistant::PersonaRegistry.find(persona)
  end

  def call(user_question)
    embed_query(user_question)

    retrieve_documents

    generate_response(user_question)
  end

  private

  def embed_query(user_question)
    query_embedding = QueryEmbeddingService.new(user_question)

    @question_embedding ||= query_embedding.call
  end

  def generate_response(question)
    response_generator = ResponseGeneratorService.new(
                          @client,
                          @model,
                          @persona
                        )

    response_generator.call(question, @documents)
  end

  def retrieve_documents
    document_retriever = DocumentRetrieverService.new(@question_embedding)

    @documents ||= document_retriever.call
  end
end
