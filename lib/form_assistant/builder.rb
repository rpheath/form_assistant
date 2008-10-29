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
        
        def for(template, binding = nil)
          element = collection[0]
          options = collection[1]
          content = collection[2]
          if binding
            template.concat(template.content_tag(element, content, options), binding)
          else
            template.content_tag(element, content, options)
          end
        end
      end
  end
end