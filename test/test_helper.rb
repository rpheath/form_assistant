ENV["RAILS_ENV"] ||= "test"
$:.unshift(File.join(File.dirname(__FILE__), *%w[../lib]))

require 'test/unit'
require 'rubygems'
require 'ostruct'

gem 'activesupport'
require 'active_support'
 
gem 'actionpack'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view/test_case'

gem 'activerecord'
require 'active_record'

gem 'mocha'
require 'mocha'

require 'mock_rails'
require 'form_assistant'