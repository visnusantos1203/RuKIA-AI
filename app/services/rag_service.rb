# frozen_string_literal: true

class RagService
  # byebug
  DEFAULT_MODEL = "gpt-3.5-turbo"
  DEFAULT_PERSONA = :professional

  def initialize(
    client: Llm::OpenAI::Client.new,
    model: DEFAULT_MODEL,
    persona: DEFAULT_PERSONA,
    document: nil
  )
    @client = client
    @model = model
    @persona = AIAssistant::PersonaRegistry.find(persona)
    @document = document
  end

  def call(user_question)
    embed_query(user_question)

    retrieve_documents

    generate_response(user_question)
  rescue AIAssistant::Errors::EmbeddingError => e
    raise e
  rescue AIAssistant::Errors::ResponseRecordingError => e
    raise e
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
    document_retriever = DocumentRetrieverService.new(
      @question_embedding,
      @document)

    @documents ||= document_retriever.call
  end
end
