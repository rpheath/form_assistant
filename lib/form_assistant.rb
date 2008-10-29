%w(error builder collector).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

module RPH
  module FormAssistant
    private
      def wrap(tag)
        Collector.new.collect(tag)
      end
      
      def element(e, attrs, content, template, binding = nil)
        wrap(e.to_sym).having(attrs).around(content).for(template, binding)
      end
      
    public
      def div(attrs = {}, &block)
        element(:div, attrs, @template.capture(&block), @template, block.binding)
      end
      
      def p(attrs = {}, &block)
        element(:p, attrs, @template.capture(&block), @template, block.binding)
      end
      
      def submission(value = 'Save Changes', options = {})
        element(:p, options.delete(:attrs), self.submit(value, options), @template)
      end
    
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?
      
        css = { :class => method.to_s.downcase.gsub('_', '-') }
        element(:div, css, @template.capture(&block), @template, block.binding)
      end
  end
end