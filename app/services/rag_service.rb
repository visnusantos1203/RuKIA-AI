class RagService
  def initialize
    @client = OpenAI::Client.new
  end

  def query(user_question, max_context_docs: 3)
    # Generate embedding for the question
    question_embedding = generate_embedding(user_question)

    # Find relevant documents using neighbor's nearest_neighbors
    relevant_docs = Document.nearest_neighbors(
      :embedding,
      question_embedding,
      distance: "cosine"
    ).first(3)

    # Prepare context from retrieved documents
    context = relevant_docs.map do |doc|
      "#{doc.title}:\n#{doc.content}"
    end.join("\n\n")

    # Create prompt with context
    prompt = <<~PROMPT
      You are a helpful assistant. Use the following context to answer the question.
      If you cannot answer the question based on the context, say so.

      Context:
      #{context}

      Question: #{user_question}
    PROMPT

    # Get completion from OpenAI
    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.7
      }
    )

    {
      question: user_question,
      answer: response.dig("choices", 0, "message", "content"),
      sources: relevant_docs.map { |doc| doc.title }
    }
  end

  def add_document(title:, content:)
    Document.create!(title: title, content: content)
  end

  private

  def generate_embedding(text)
    response = @client.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: text
      }
    )
    response.dig("data", 0, "embedding")
  end
end
