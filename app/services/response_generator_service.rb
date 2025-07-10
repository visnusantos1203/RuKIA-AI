# frozen_string_literal: true

class ResponseGeneratorService
  def initialize(client, model, persona)
    @client = client
    @model = model
    @persona = persona
  end

  def call(question, documents)
    llm_answer = generate_llm_answer(question, documents)

    build_response(question, llm_answer, documents)
  end

  private

  def build_context(documents)
    documents.map do |doc|
      "#{doc.content}"
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
      source: "#{sources.first.document.name}",
      persona: @persona.name
    }
  end

  def generate_llm_answer(question, documents)
    return "No relevant information found." if documents.empty?

    context = build_context(documents)
    prompt = build_prompt(context, question)

    @client.query(@model, prompt)
  rescue StandardError => e
    raise AIAssistant::Errors::QueryProcessingError, "Failed to generate response: #{e.message}"
  end
end
