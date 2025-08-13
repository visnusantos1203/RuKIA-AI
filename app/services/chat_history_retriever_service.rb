# frozen_string_literal: true

class ChatHistoryRetrieverService
  def initialize(document)
    @document = document
  end

  def call
    user_messages = @document.messages.last(10).pluck(:body)
    llm_response = @document.llm_responses.last(10).pluck(:body)

    user_messages.zip(llm_response).map do |user, llm|
      { user: user, llm_response: llm }
    end
  end
end
