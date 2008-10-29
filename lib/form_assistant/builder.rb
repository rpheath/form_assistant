module RPH
  module FormAssistant
    private
      class Builder
        attr_reader :collection
        
        def initialize(collection)
          @collection = collection
        end
        
        def self.build(collection)
          new(collection)
        end
        
        def for(template)
          # magic goes here
        end
      end
  end
end