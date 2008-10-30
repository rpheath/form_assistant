require File.join(File.dirname(__FILE__), 'spec_helper')

describe "FormAssistant" do
  before(:each) do
    template = ::ActionView::Base.new
    template.controller = ::ActionController::Base.new
    @form = ActionView::Helpers::FormBuilder.new(:project, Project.new, template, {}, nil)
  end
  
  describe "submission" do
    it "should wrap submit button with <p> tag with class 'submission'" do
      @form.submission.
        should eql("<p class=\"submission\"><input id=\"project_submit\" name=\"commit\" type=\"submit\" value=\"Save Changes\" /></p>")
    end
    
    it "should allow for different submit button value" do
      @form.submission('Save Project').
        should eql("<p class=\"submission\"><input id=\"project_submit\" name=\"commit\" type=\"submit\" value=\"Save Project\" /></p>")
    end
    
    it "should allow for different attributes on the <p> tag" do
      @form.submission('Save Project', :attrs => { :class => 'submit' }).
        should eql("<p class=\"submit\"><input id=\"project_submit\" name=\"commit\" type=\"submit\" value=\"Save Project\" /></p>")
    end
    
    it "should allow for changes made to the options of the submit button" do
      @form.submission('Save Project', :class => 'button').
        should eql("<p class=\"submission\"><input class=\"button\" id=\"project_submit\" name=\"commit\" type=\"submit\" value=\"Save Project\" /></p>")
    end
  end
  
  # TODO: find motivation to finish writing specs
  
  describe "div, p, and span" do
    # ...
  end
  
  describe "cancel" do
    # ...
  end
  
  describe "method_missing hook" do
    # ...
  end
end