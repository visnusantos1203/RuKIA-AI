require 'rails_helper'

RSpec.describe Document, type: :model do
  let(:document) { FactoryBot.build(:document) }

  context 'Should validate' do
    it 'with title, content, embeddings' do
      expect(document).to be_valid
    end
  end

  context 'Should not validate' do
    it 'without title' do
      document.title = nil
      expect(document).not_to be_valid
    end

    it 'without content' do
      document.content = nil
      expect(document).not_to be_valid
    end

    it 'without embeddings' do
      document.embedding = nil
      expect(document).not_to be_valid
    end
  end

  context 'Embedding size' do
    it 'should be 1536' do
      document.embedding = (1..1536).to_a
      expect(document).to be_valid
    end

    it 'should not be less than 1536' do
      document.embedding = [ 0, 1, 2 ]
      expect(document).not_to be_valid
    end
  end
end
