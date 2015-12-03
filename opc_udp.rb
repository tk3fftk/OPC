#encoding: utf-8

require 'socket'
require 'rubygems'
require 'eventmachine'
require './opc_rtp_parser'

class UdpServer < EM::Connection
	@@host = ''
	@@port = 5555
	@@jpeg = 0
	@@parser = RTPParser.new

	# override データを受信する度に実行される
	def receive_data data
		parseRTP data
	end

	def self.run
		# UDPサーバー起動
		EM::run do
			EM::open_datagram_socket(@@host, @@port, self)
		end
	end

	def parseRTP pkt
		@@parser.parse pkt
	end
end
