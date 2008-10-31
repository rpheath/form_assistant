module RPH
  module FormAssistant
    # stores all form helpers
    FORM_HELPERS = [
      ActionView::Helpers::FormBuilder.field_helpers + 
      %w(date_select datetime_select time_select collection_select select country_select time_zone_select) - 
      %w(hidden_field label fields_for)
    ].flatten.freeze
    
    module Helpers
      ELEMENTS = [:div, :span, :p].freeze
      
      # extend convenience methods
      def self.included(receiver)
        receiver.extend ClassMethods
      end
      
    private
      # wrapper(): used to easily add new methods to the FormAssistant
      #
      # Parameters:
      #   e         - the element that wraps the content
      #   attrs     - the attributes for that element (class, id, etc)
      #   content   - the actual content to wrap
      #   binding   - optional binding (required if a block is passed)
      #
      # Ex:
      #   def span(attrs = {}, &block)
      #     wrapper(:span, attrs, @template.capture(&block), block.binding)
      #   end
      def wrapper(e, attrs, content, binding = nil)
        Collector.wrap(e).having(attrs).around(content).for(@template, binding)
      end
      
    public      
      # submission(): used to generate the 'submit' button on a form
      # 
      # Parameters:
      #   value   - the button's value
      #   options - options that you'd normally pass to a submit() helper
      #             (Note: for attributes on the wrapper, use :attrs => { ... })
      #
      # Ex:
      #   <% form_for @project do |form| %>
      #     // form stuff
      #     <%= form.submission 'Save Project' %>
      #   <% end %>
      def submission(value = 'Save Changes', options = {})
        wrapper(:p, { :class => 'submission' }.merge!(options.delete(:attrs) || {}), self.submit(value, options))
      end

      # cancel(): used to provide a "go back" method while on a form
      # 
      # Ex:
      #   <% form_for @project do |form| %>
      #     // form stuff
      #     <%= form.cancel %>
      #   <% end %>
      #
      # Other options inlude:
      #   <%= form.cancel 'Go Back' %>
      #   <%= form.cancel 'Go Back', :url => some_path %>
      def cancel(*args)
        options = {
          :text => (args.first if args.first.is_a?(String)) || 'Cancel',
          :path => (@template.request.env['HTTP_REFERER'] || @template.send("#{@object_name.to_s.pluralize}_path")),
          :attrs => { :class => 'cancel' }
        }.merge!(args.last.is_a?(Hash) ? args.pop : {})

        wrapper(:span, options.delete(:attrs), @template.link_to(options.delete(:text), options.delete(:path), options))
      end

      # This hook provides convenient way to wrap content with a div,
      # where the "missing method" becomes the CSS class for the div.
      # 
      # Ex:
      #   <% form_for @project do |form| %>
      #     <% form.admin_operations do %>
      #       // admin stuff
      #     <% end %>
      #   <% end %>
      #
      #   <form ... >
      #     <div class="admin-operations">
      #       // admin stuff
      #     </div>
      #   </form>
      #
      # Any underscored methods will become a dasherized CSS class by
      # default; however, if you'd rather the underscored method translate
      # to multiple CSS classes, pass a :glue => ' ' option
      #
      #   <% form.admin_operations :glue => ' ' do %>
      #     // admin operations stuff
      #   <% end %>
      #
      #   <div class="admin operations">
      #     // admin operations stuff
      #   </div>
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?

        options, attrs, element = (args.last.is_a?(Hash) ? args.pop : {}), {}, nil

        if ELEMENTS.include?(method.to_sym)
          attrs, element = options, method
        else 
          attrs, element = { :class => method.to_s.downcase.gsub('_', options[:glue] || '-') }, :div 
        end

        wrapper(element, attrs, @template.capture(&block), block.binding)
      end
      
      module ClassMethods
        protected
          def form_helpers
            ::RPH::FormAssistant::FORM_HELPERS
          end
      end
    end
  end
end