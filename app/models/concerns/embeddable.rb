# frozen_string_literal: true

module Embeddable
  extend ActiveSupport::Concern

  # included do
  #   # attr_accessor :content
  # end

  class_methods do
    private

    def generate_embedding(content)
      embedding_service = EmbeddingService.new(content)

      embedding_service.call
    end
  end
end
