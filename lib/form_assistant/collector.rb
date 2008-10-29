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
        
        def for(template)
          Builder.build(collection).for(template)
        end
      end
  end
end