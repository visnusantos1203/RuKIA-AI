FactoryBot.define do
  factory :message do
    body { "MyString" }
    embedding { "" }
    token_count { 1 }
    document { nil }
  end
end
