module RPH
  module FormAssistant
    private
      class Collector
        def initialize
          @items = []
        end
        
        def collect(item)
          @items << item and return self
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
        
      private
        def collection
          @items
        end
      end
  end
end