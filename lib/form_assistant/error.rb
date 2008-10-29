module RPH
  module FormAssistant
    class Error < RuntimeError
      def self.message(msg=nil)
        msg.nil? ? @message : self.message = msg 
      end
      
      def self.message=(msg)
        @message = msg 
      end
    end
    
    class InvalidAttributes < Error
      message "Must pass a Hash of attributes to having()" end
  end
end