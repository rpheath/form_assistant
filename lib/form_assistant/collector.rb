module RPH
  module FormAssistant
    private
      class Collector
        attr_accessor :collection
        
        def initialize
          @collection = []
        end
        
        def collect(item)
          collection << item and return self
        end
        
        def having(attrs = {})
          collect(attrs)
        end
        
        def around(content)
          collect(content)
        end
        
        def for(template, binding = nil)
          Builder.build(collection).for(template, binding)
        end
      end
  end
end