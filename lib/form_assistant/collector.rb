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
        
        def collection
          @items
        end
        
        def having(attrs = {})
          collect(attrs)
        end
        
        def around(content = nil, &block)
          collect(content)
        end
        
        def for(template, binding = nil)
          Builder.build(collection).for(template, binding)
        end
      end
  end
end