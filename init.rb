require 'form_assistant'
ActionView::Helpers::FormBuilder.send :include, RPH::FormAssistant
ActionView::Base.send :include, RPH::FormAssistant::InstanceMethods