%w(error rules builder collector helpers field_errors).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

# Developed by Ryan Heath (http://rpheath.com)
module RPH
  # The idea is to make forms extremely less painful and a lot more DRY
  module FormAssistant
    # FormAssistant::FormBuilder
    #   * provides several convenient helpers (see helpers.rb) and
    #     an infrastructure to easily add your own
    #   * method_missing hook to wrap content "on the fly"
    #   * optional: automatically attach labels to field helpers
    #   * optional: format fields using partials (extremely extensible)
    # 
    # Usage:
    #
    #   <% form_for @project, :builder => RPH::FormAssistant::FormBuilder do |form| %>
    #     // fancy form stuff
    #   <% end %>
    #
    #   - or -
    # 
    #   <% form_assistant_for @project do |form| %>
    #     // fancy form stuff
    #   <% end %>
    #
    #   - or -
    #
    #   # in config/intializers/form_assistant.rb
    #   ActionView::Base.default_form_builder = RPH::FormAssistant::FormBuilder
    class FormBuilder < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      cattr_accessor :ignore_templates
      cattr_accessor :ignore_labels
      cattr_accessor :ignore_errors
      cattr_accessor :template_root
      
      # used if no other template is available
      attr_accessor_with_default :fallback_template, 'field'
      
      # if set to true, none of the templates will be used;
      # however, labels can still be automatically attached
      # and all FormAssistant helpers are still avaialable
      self.ignore_templates = false
      
      # if set to true, labels will become nil everywhere (both 
      # with and without templates)
      self.ignore_labels = false
      
      # set to true if you'd rather use #error_messages_for()
      self.ignore_errors = false

      # sets the root directory where templates will be searched
      # note: the template root should be nested within the
      # configured view path (which defaults to app/views)
      self.template_root = File.join(Rails.configuration.view_path, 'forms')
      
      # override the field_error_proc so that it no longer wraps the field
      # with <div class="fieldWithErrors">...</div>, but just returns the field
      ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
      
    private
      # render(:partial => '...') doesn't want the full path of the template
      def self.template_root(full_path = false)
        full_path ? @@template_root : @@template_root.gsub(Rails.configuration.view_path + '/', '')
      end
      
      # get the error messages (if any) for a field
      def error_message_for(field)
        return nil unless has_errors?(field)
        
        errors = if RPH::FormAssistant::Rules.has_I18n_support?
          full_messages_for(field)
        else
          errors = object.errors[field]
          [[field.to_s.humanize, (errors.is_a?(Array) ? errors.to_sentence : errors).to_s].join(' ')]
        end
        
        RPH::FormAssistant::FieldErrors.new(errors)
      end
      
      # Returns full error messages for given field (uses I18n)
      def full_messages_for(field)
        attr_name = object.class.human_attribute_name(field.to_s)

        object.errors[field].inject([]) do |full_messages, message|
          next unless message
          full_messages << attr_name + I18n.t('activerecord.errors.format.separator', :default => ' ') + message
        end
      end
      
      # returns true if a field is invalid
      def has_errors?(field)
        !(object.nil? || object.errors[field].blank?)
      end
      
      # checks to make sure the template exists
      def template_exists?(template)
        File.exists?(File.join(self.class.template_root(true), "_#{template}.html.erb"))
      end
      
    protected
      # renders the appropriate partial located in the template root
      def render_partial_for(element, field, label, tip, template, helper, required, extra_locals, args)
        errors = self.class.ignore_errors ? nil : error_message_for(field)
        locals = extra_locals.merge(:element => element, :field => field, :builder => self, :object => object, :object_name => object_name, :label => label, :errors => errors, :tip => tip, :helper => helper, :required => required)

        @template.render :partial => "#{self.class.template_root}/#{template}.html.erb", :locals => locals
      end
      
      # render the element with an optional label (does not use the templates)
      def render_element(element, field, name, options, ignore_label = false)
        return element if ignore_label
        
        # need to consider if the shortcut label option was used
        # i.e. <%= form.text_field :title, :label => 'Project Title' %>
        text, label_options = if options[:label].is_a?(String)
          [options.delete(:label), {}]
        else
          [options[:label].delete(:text), options.delete(:label)]
        end
        
        # consider trailing labels
        if %w(check_box radio_button).include?(name)
          label_options[:class] = (label_options[:class].to_s + ' inline').strip
          element + label(field, text, label_options)
        else
          label(field, text, label_options) + element
        end
      end
    
      def extract_options_for_label(field, options={})
        label_options = {}

        # consider the global setting for labels and
        # allow for turning labels off on a per-helper basis
        # <%= form.text_field :title, :label => false %>
        if self.class.ignore_labels || options[:label] === false || field.blank?
          label_options[:label] = false
        else  
          # ensure that the :label option is a Hash from this point on
          options[:label] ||= {}
        
          # allow for a cleaner way of setting label text
          # <%= form.text_field :whatever, :label => 'Whatever Title' %>
          label_options.merge!(options[:label].is_a?(String) ? {:text => options[:label]} : options[:label])

          # allow for a more convenient way to set common label options
          # <%= form.text_field :whatever, :label_id => 'dom_id' %>
          # <%= form.text_field :whatever, :label_class => 'required' %>
          # <%= form.text_field :whatever, :label_text => 'Whatever' %>
          %w(id class text).each do |option|
            label_option = "label_#{option}".to_sym
            label_options.merge!(option.to_sym => options.delete(label_option)) if options[label_option]
          end
        
          # Ensure we have default label text 
          # (since Rails' label() does not currently respect I18n)
          label_options[:text] ||= object.class.human_attribute_name(field.to_s)
        end
          
        label_options
      end
      
      def extract_options_for_template(helper_name, options={})
        template_options = {}
        
        if options.has_key?(:template) && options[:template].kind_of?(FalseClass)
          template_options[:template] = false
        else  
          # grab the template
          template = options.delete(:template) || helper_name.to_s
          template = self.fallback_template unless template_exists?(template)
          template_options[:template] = template
        end
          
        template_options
      end  
    
    public
      def self.assist(helper_name)
        define_method(helper_name) do |field, *args|
          options          = (helper_name == 'check_box' ? args.shift : args.extract_options!) || {}
          label_options    = extract_options_for_label(field, options)
          template_options = extract_options_for_template(helper_name, options)
          extra_locals     = options.delete(:locals) || {}
          
          # build out the label element (if desired)
          label = label_options[:label] === false ? nil : self.label(field, label_options.delete(:text), label_options)

          # grab the tip, if any
          tip = options.delete(:tip)
          
          # is the field required?
          required = !!options.delete(:required)
          
          # ensure that we don't have any custom options pass through
          field_options = options.except(:label, :template, :tip, :required)
          
          # call the original render for the element
          super_args = helper_name == 'check_box' ? args.unshift(field_options) : args.push(field_options)
          element = super(field, *super_args)
          
          return element if template_options[:template] === false
          
          # return the helper with an optional label if templates are not to be used
          return render_element(element, field, helper_name, options, label_options[:label] === false) if self.class.ignore_templates
          
          # render the partial template from the desired template root
          render_partial_for(element, field, label, tip, template_options[:template], helper_name, required, extra_locals, args)
        end
      end
      
      # redefining all traditional form helpers so that they
      # behave the way FormAssistant thinks they should behave
      send(:form_helpers).each do |helper_name|
        assist(helper_name)
      end
    
      def without_assistance(options={}, &block)
        # TODO - allow options to only turn off templates and/or labels
        ignore_labels, ignore_templates = self.class.ignore_labels, self.class.ignore_templates
       
        begin
          self.class.ignore_labels, self.class.ignore_templates = true, true
          result = yield
        ensure  
          self.class.ignore_labels, self.class.ignore_templates = ignore_labels, ignore_templates
        end  

        result
      end
    
      def widget(*args, &block)
        options          = args.extract_options!
        field            = args.shift || nil 
        label_options    = extract_options_for_label(field, options)
        template_options = extract_options_for_template(self.fallback_template, options)
        label            = label_options[:label] === false ? nil : self.label(field, label_options.delete(:text), label_options)
        tip              = options.delete(:tip)
        required         = !!options.delete(:required)

        element = without_assistance do
          @template.capture(&block)
        end  
        
        partial = render_partial_for(element, field, label, tip, template_options[:template], 'widget', required, {}, args)
        RPH::FormAssistant::Rules.binding_required? ? @template.concat(partial, block.binding) : @template.concat(partial)
      end
      
      # Renders a partial, passing the form object as a local
      # variable named 'form'
      # <%= form.partial 'shared/new', :locals => { :whatever => @whatever } %>
      def partial(name, options={})
        (options[:locals] ||= {}).update :form => self
        options.update :partial => name
        @template.render options
      end
      
      # since #fields_for() doesn't inherit the builder from form_for, we need
      # to provide a means to set the builder automatically (works with nesting, too)
      #
      # Usage: simply call #fields_for() on the builder object
      #
      #   <% form_assistant_for @project do |form| %>
      #     <%= form.text_field :title %>
      #     <% form.fields_for :tasks do |task_fields| %>
      #       <%= task_fields.text_field :name %>
      #     <% end %>
      #   <% end %>
      def fields_for_with_form_assistant(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        # hand control over to the original #fields_for()
        fields_for_without_form_assistant(record_or_name_or_array, *(args << options.merge!(:builder => self.class)), &proc)
      end
      
      # used to intercept #fields_for() and set the builder
      alias_method_chain :fields_for, :form_assistant
    end
    
    # methods that mix into ActionView::Base
    module ActionView
      private
        # used to ensure that the desired builder gets set before calling #form_for()
        def form_for_with_builder(record_or_name_or_array, builder, *args, &proc)
          options = args.extract_options!
          # hand control over to the original #form_for()
          form_for(record_or_name_or_array, *(args << options.merge!(:builder => builder)), &proc)
        end
        
        # determines if binding is needed for #concat()
        # (Rails 2.2.0 and greater no longer requires the binding)
        def binding_required
          RPH::FormAssistant::Rules.binding_required?
        end
      
      public
        # easy way to make use of FormAssistant::FormBuilder
        #
        # <% form_assistant_for @project do |form| %>
        #   // fancy form stuff
        # <% end %>
        def form_assistant_for(record_or_name_or_array, *args, &proc)
          form_for_with_builder(record_or_name_or_array, RPH::FormAssistant::FormBuilder, *args, &proc)
        end
        
        # (borrowed the #fieldset() helper from Chris Scharf: 
        #   http://github.com/scharfie/slate/tree/master/app/helpers/application_helper.rb)
        #
        # <% fieldset 'User Registration' do %>
        #   // fields
        # <% end %>
        def fieldset(legend, &block)
          locals = { :legend => legend, :fields => capture(&block) }
          partial = render(:partial => "#{RPH::FormAssistant::FormBuilder.template_root}/fieldset.html.erb", :locals => locals)
          
          # render the fields
          binding_required ? concat(partial, block.binding) : concat(partial)
        end
    end
  end   
end