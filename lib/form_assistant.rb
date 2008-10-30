%w(error builder collector).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

# FormAssistant is a module that mixes into the FormBuilder class. It
# provides for a very simple way to extend the functionality of forms
#
# This is currently somewhat tailored to how I personally use forms -
# The idea is that the public methods should be modified (or added/removed)
# to accommodate how you use forms in Rails. Of course, feel free to adopt
# my patterns that I've laid out here.
module RPH
  module FormAssistant
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
      # div(): used to wrap a div around a block of content
      # 
      # Parameters:
      #   attrs   - the attributes for the <div> element
      #   &block  - the block of content that the <div> should wrap
      #
      # Ex:
      #   <% form_for @project do |form| %>
      #     <%= form.div :class => 'admin' do %>
      #       // your content
      #     <% end %>
      #   <% end %>
      def div(attrs = {}, &block)
        wrapper(:div, attrs, @template.capture(&block), block.binding)
      end
      
      # see div()
      def p(attrs = {}, &block)
        wrapper(:p, attrs, @template.capture(&block), block.binding)
      end
      
      # see div() or p()
      def span(attrs = {}, &block)
        wrapper(:span, attrs, @template.capture(&block), block.binding)
      end
      
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
        
        options = args.last.is_a?(Hash) ? args.pop : {}
        css = { :class => method.to_s.downcase.gsub('_', options[:glue] || '-') }
        wrapper(:div, css, @template.capture(&block), block.binding)
      end
  end
end