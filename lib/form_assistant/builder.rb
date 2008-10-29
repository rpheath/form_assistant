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
        
        def for(template, binding)
          element = collection[0]
          options = collection[1]
          content = collection[2]
          
          content_tag = template.content_tag(element, content, options)
          binding ? template.concat(content_tag, binding) : content_tag
        end
      end
  end
end