#encoding: utf-8

require 'socket'
require 'rubygems'
require 'websocket-client-simple'
require 'eventmachine'

class UdpServer < EM::Connection
	@@host = ''
	@@port = 5555

	# override データを受信する度に実行される
	def receive_data data
		#img = @live_socket.recvfrom_nonblock(65535) #受け取るバイト数？
		p data
		#@ws.send data
	end

	def self.run
		# websocketコネクション
		@ws = WebSocket::Client::Simple.connect 'ws://localhost:3001'

		EM::run do
			EM::open_datagram_socket(@@host, @@port, self)
		end
	end
end
