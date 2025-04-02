module AIAssistant
  module Errors
    class Base < StandardError; end
    
    class PersonaError < Base; end
    class PersonaNotFoundError < PersonaError; end
    class InvalidPersonaError < PersonaError; end
    
    class LLMError < Base; end
    class ModelNotSupportedError < LLMError; end
    class ConnectionError < LLMError; end
    class TimeoutError < LLMError; end
    class RateLimitError < LLMError; end
    
    class EmbeddingError < Base; end
    class EmbeddingGenerationError < EmbeddingError; end
    
    class DocumentError < Base; end
    class DocumentCreationError < DocumentError; end
    class DocumentNotFoundError < DocumentError; end
    class InvalidDocumentError < DocumentError; end
    
    class QueryError < Base; end
    class InvalidQueryError < QueryError; end
    class QueryProcessingError < QueryError; end
  end
end 