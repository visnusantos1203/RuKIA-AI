FactoryBot.define do
  factory :document do
    title { '2025 Guidelines' }
    content { 'Our return policy is designed to ensure customer satisfaction. Items can be returned within 30 days of purchase with a valid receipt. All items must be in their original condition with tags attached. For online purchases, shipping costs will be refunded only if the return is due to our error. Customized items are non-returnable unless defective. Electronics must be returned within 14 days and cannot be returned if opened unless defective.' }
    embedding { (1..1536).to_a }
  end
end
