module RPH
  module FormAssistant
    private
      # used to assist generic logic throughout FormAssistant
      class Rules
        # used mainly for #concat() so that this plugin will
        # work with versions of Rails other than edge
        def self.binding_required?
          !!((Object.const_defined?(:Rails) && Rails.respond_to?(:version) ? 
              Rails.version : RAILS_GEM_VERSION) < '2.2.0')
        end
      end
  end
end