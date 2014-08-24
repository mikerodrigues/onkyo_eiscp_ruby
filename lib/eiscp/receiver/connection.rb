module EISCP
  class Receiver
    module Connection

      # Receiver's connection socket
      attr_reader :socket
      # Receiver's connection thread
      attr_reader :thread
      # Most recent message received
      attr_reader :last

      DEFAULT_TIMEOUT = 0.5

      # This handles the background thread for monitoring messages from the
      # receiver.
      #
      # If a block is given, it can be used to setup a callback when a message
      # is received.
      #
      def connect(host, port = 60128, block = nil)
        begin
        @socket = TCPSocket.new(host, port)
        @thread = Thread.new do
          loop do
            recv
            if block
              block.call(msg)
            end
          end
        end
        rescue => e
          puts e
        end
      end

      # Sends an EISCP::Message object or string on the network
      #
      def send(eiscp, timeout = DEFAULT_TIMEOUT)
        if eiscp.is_a? EISCP::Message
          @socket.puts(eiscp.to_eiscp)
        elsif eiscp.is_a? String
          @socket.puts eiscp
        end
      end

      def recv(timeout = DEFAULT_TIMEOUT)
        message = ""
        until message.match(/\r\n$/) do
          message << @socket.gets
        end
        @last = message
      end

      # Sends an EISCP::Message object or string on the network and returns recieved data string.
      #
      def send_recv(eiscp, timeout = DEFAULT_TIMEOUT)
        if eiscp.is_a? EISCP::Message
          @socket.puts(eiscp.to_eiscp)
        elsif eiscp.is_a? String
          @socket.puts(eiscp)
        end
        sleep 0.1
        last
      end

    end
  end
end
