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
      
      def wrap(tag, options = {}, content = nil, &block)
        Collector.new.collect(tag)
      end
      
    public
      def div(attrs = {}, &block)
        wrap(:div).having(attrs).around(@template.capture(&block)).for(@template)
      end
    
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?
      
        css = method.to_s.downcase.gsub('_', '-')
        @template.concat(@template.content_tag(:div, :class => css) do
          @template.capture(&block)
        end, block.binding)
      end
  end
end