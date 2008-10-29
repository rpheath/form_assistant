%w(error builder collector).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

module RPH
  module FormAssistant
    private
      def wrap(tag)
        Collector.new.collect(tag)
      end
      
    public
      def div(attrs = {}, &block)
        wrap(:div).having(attrs).around(@template.capture(&block)).for(@template)
      end
    
      def method_missing(method, *args, &block)
        super(method, *args) unless block_given?
      
        css = method.to_s.downcase.gsub('_', '-')
        @template.concat(@template.content_tag(:div, :class => css) do
          @template.capture(&block)
        end, block.binding)
      end
  end
end