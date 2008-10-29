%w(error builder collector).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

module RPH
  module FormAssistant
    private
      def wrapper(e, attrs, content, binding = nil)
        Collector.wrap(e).having(attrs).around(content).for(@template, binding)
      end
      
    public
      def div(attrs = {}, &block)
        wrapper(:div, attrs, @template.capture(&block), block.binding)
      end
      
      def p(attrs = {}, &block)
        wrapper(:p, attrs, @template.capture(&block), block.binding)
      end
      
      def submission(value = 'Save Changes', options = {})
        wrapper(:p, options.delete(:attrs), self.submit(value, options))
      end
    
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?
      
        css = { :class => method.to_s.downcase.gsub('_', '-') }
        wrapper(:div, css, @template.capture(&block), block.binding)
      end
  end
end