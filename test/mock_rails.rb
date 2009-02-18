unless Object.const_defined?(:Rails)
  class Rails
    class << self
      attr_accessor :root, :version

      def root
        @root ||= File.dirname(__FILE__)
      end
  
      def version
        @version ||= '2.2.2'
      end
      
      def configuration
        @configuration ||= Configuration.new
      end
    end
    
    class Configuration
      attr_accessor :view_path
      
      def view_path
        @view_path ||= ''
      end
    end
  end
end