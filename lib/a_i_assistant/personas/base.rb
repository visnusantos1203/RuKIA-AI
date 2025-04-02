module AIAssistant
  module Personas
    class Base
      def system_prompt
        raise NotImplementedError, "#{self.class} must implement system_prompt"
      end

      def name
        self.class.name.demodulize.underscore.humanize
      end

      def description
        raise NotImplementedError, "#{self.class} must implement description"
      end
    end
  end
end 