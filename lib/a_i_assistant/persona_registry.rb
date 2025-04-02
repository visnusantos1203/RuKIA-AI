module AIAssistant
  class PersonaRegistry
    class << self
      def all
        @all ||= {
          # App personas
          professional: Personas::Professional.new,
          friendly: Personas::Friendly.new,
          technical: Personas::Technical.new,
          sarcastic: Personas::Sarcastic.new,
          du30: Personas::Du30.new,
          mimiyuh: Personas::Mimiyuh.new
        }
      end

      def find(name)
        all[name.to_sym] || all[:professional]
      end

      def available_personas
        all.map do |key, persona|
          {
            id: key,
            name: persona.name,
            description: persona.respond_to?(:description) ? persona.description : "A unique AI assistant with a distinct personality."
          }
        end
      end
    end
  end
end 