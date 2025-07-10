FactoryBot.define do
  factory :llm_response do
    body { "MyString" }
    token_count { 1 }
    persona { "MyString" }
    source { "MyString" }
    message { nil }
  end
end
