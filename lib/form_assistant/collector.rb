module RPH
  module FormAssistant
    private
      class Collector
        attr_accessor :collection
      
      private
        def collect(item)
          collection << item and return self
        end
      
      public
        def self.wrap(element)
          new.collect(element.to_sym)
        end
        
        def initialize
          @collection = []
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