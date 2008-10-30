require 'rubygems'
require 'action_view'
require 'action_controller'
require File.join(File.dirname(__FILE__), '..', 'lib', 'form_assistant')

ActionView::Helpers::FormBuilder.send :include, RPH::FormAssistant

class Project
end