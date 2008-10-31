module RPH
  module FormAssistant
    private
      # The Builder class constructs the output
      # based on the collection it was handed
      class Builder
        attr_reader :collection
      
      private
        def binding_required
          !!((Object.const_defined?(:Rails) && Rails.respond_to?(:version) ? 
              Rails.version : RAILS_GEM_VERSION) < '2.2.0')
        end
        
      public  
        # convenience method to build output from a collection
        def self.build(collection)
          new(collection)
        end
        
        # new collection
        def initialize(collection)
          @collection = collection
        end
        
        # builds the output
        #
        # if a binding is passed, that indicates that the content
        # was a block and needs to be handled accordingly
        def for(template, binding)
          element = collection[0]
          options = collection[1]
          content = collection[2]
          
          content_tag = template.content_tag(element, content, options)
          binding ? (binding_required ? template.concat(content_tag, binding) : template.concat(content_tag)) : content_tag
        end
      end
  end
end