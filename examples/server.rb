require 'rubygems'
require 'eventmachine'
 
__DIR__ = File.dirname File.expand_path(__FILE__)
 
EM.run{
 
  class FlashServer < EM::Connection
    def self.start host, port
      puts ">> FlashServer started on #{host}:#{port}"
      EM.start_server host, port, self
    end
 
    def post_init
      @ip = Socket.unpack_sockaddr_in(get_peername).last rescue '0.0.0.0'
      puts ">> FlashServer got connection from #{@ip}"
    end
 
    def unbind
      @timer.cancel if @timer
      puts ">> FlashServer got disconnect from #{@ip}"
    end
 
    def receive_data data
      p data
      if data.strip == "<policy-file-request/>"
        send_data %[
          <?xml version="1.0"?>
          <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
          <cross-domain-policy>
            <allow-access-from domain="*" to-ports="*" />
          </cross-domain-policy>\0
        ]
        close_connection_after_writing
        return
      end
      puts "Data: #{data.inspect}"
      send_data data
    end
 
  end
  
  flash = FlashServer.start  'localhost', 1234
  
}