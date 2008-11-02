%w(error builder collector helpers).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

# Developed by Ryan Heath (http://rpheath.com)
module RPH
  # FormAssistant is currently made up of two custom FormBuilder's:
  #
  #   FormAssistant::FormBuilder
  #     - provides several convenient helpers (see helpers.rb)
  #     - method_missing hook to wrap content "on the fly"
  #     - labels automatically attached to field helpers
  #
  #   FormAssistant::InlineErrorFormBuilder
  #     - inherits from FormBuilder, so has all of the above functionality
  #     - provides errors inline with the field that wraps it
  #     - uses partials (in views/forms/) to style fields
  #
  # The idea is to make forms extremely less painful and a lot more DRY
  module FormAssistant
    # custom form builder
    # 
    # <% form_for @project, :builder => RPH::FormAssistant::FormBuilder do |form| %>
    #   // form stuff
    # <% end %>
    #
    # Note: see #form_assistant_for() below for an easier way to use this builder
    class FormBuilder < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      class_inheritable_accessor :wrap_fields_with_paragraph_tag
      
      # set to true if you want the <label> and the <field>
      # to be automatically wrapped in a <p> tag
      # 
      # Note: this can be set in config/initializers/form_assistant.rb ...
      #   RPH::FormAssistant::FormBuilder.wrap_fields_with_paragraph_tag = true
      self.wrap_fields_with_paragraph_tag = false
      
    public
      # redefining all traditional form helpers so that they
      # behave the way FormAssistant thinks they should behave
      send(:form_helpers).each do |name|
        define_method name do |field, *args|
          # pull out the options
          options = args.detect { |arg| arg.is_a?(Hash) } || {}
          
          options[:label] ||= {}
          # allow for a more convenient way to set common label options
          %w(text class).each do |option|
            label_option = "label_#{option}".to_sym
            options[:label].merge!(option.to_sym => options.delete(label_option)) if options[label_option]
          end
          
          # return the fields
          label_with_field = label(field, options[:label].delete(:text), options.delete(:label)) + super
          self.class.wrap_fields_with_paragraph_tag ? @template.content_tag(:p, label_with_field) : label_with_field
        end
      end
    end
    
    # extends the custom form builder above to attach form errros to 
    # the fields themselves, avoiding the <%= error_messages_for :object %> way
    # 
    # <% form_for @project, :builder => RPH::FormAssistant::InlineErrorFormBuilder do |form| %>
    #   // form stuff
    # <% end %>
    #
    # Note: see #inline_error_form_assistant_for() below for an easier way to use this builder
    class InlineErrorFormBuilder < FormBuilder
      # override the field_error_proc so that it no longer wraps the field
      # with <div class="fieldWithErrors">...</div>, but just returns the field
      ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
      
      # ensure that fields are NOT wrapped with <p> tags 
      # (handle markup formatting in forms/_partials)
      self.wrap_fields_with_paragraph_tag = false
      
    private
      # get the error messages (if any) for a field
      def error_message(field)
        return unless has_errors?(field)
        errors = object.errors.on(field)
        errors.is_a?(Array) ? errors.to_sentence : errors
      end
      
      # returns true if a field is invalid or the object is missing
      def has_errors?(field)
        !(object.nil? || object.errors.on(field).blank?)
      end
    
    public
      # redefining the custom FormBuilder's methods
      send(:form_helpers).each do |name|
        define_method name do |field, *args|
          # use partials located in app/views/forms to
          # handle the representation of the fields
          render_partial_for(field) { super }
        end
      end
      
      # render the appropriate partial based on whether or not
      # the field has any errors
      def render_partial_for(field)
        @template.capture do
          # get the field/label combo provided by FormBuilder
          locals = { :field_with_label => yield }
          
          # determine which partial to render based on if
          # the field has any errors associated with it
          if has_errors?(field)
            locals.merge! :errors => error_message(field)
            @template.render :partial => 'forms/field_with_errors', :locals => locals
          else
            @template.render :partial => 'forms/field_without_errors', :locals => locals
          end
        end
      end
    end
    
    # methods that mix into ActionView::Base
    module ActionView
      private
        # used to ensure that the desired builder gets set before calling form_for()
        def form_for_with_builder(record_or_name_or_array, builder, *args, &proc)
          options = (args.detect { |arg| arg.is_a?(Hash) } || {}).merge! :builder => builder
          args << options
          
          # hand control over to the regular form_for()
          form_for(record_or_name_or_array, *args, &proc)
        end
      
      public
        # easy way to make use of FormAssistant::FormBuilder
        #
        # <% form_assistant_for @project do |form| %>
        #   // form stuff
        # <% end %>
        def form_assistant_for(record_or_name_or_array, *args, &proc)
          form_for_with_builder(record_or_name_or_array, RPH::FormAssistant::FormBuilder, *args, &proc)
        end
      
        # easy way to make use of FormAssistant::InlineErrorFormBuilder
        #
        # <% inline_error_form_assistant_for @project do |form| %>
        #   // form stuff
        # <% end %>
        def inline_error_form_assistant_for(record_or_name_or_array, *args, &proc)
          form_for_with_builder(record_or_name_or_array, RPH::FormAssistant::InlineErrorFormBuilder, *args, &proc)
        end
    end
  end   
end