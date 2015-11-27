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
		#@ws.send data
	end

	def self.run
		# UDPサーバー起動
		EM::run do
			EM::open_datagram_socket(@@host, @@port, self)
		end
	end

	def parseRTP pkt
		#p pkt[0].unpack("B*")[0][0..1] # VVPXCCCC
		#p pkt[1].unpack("B*")[0] # MPTPTPTP
		#p pkt[2..3].unpack("B*")[0] # sequence num
		#p pkt[4..7].unpack("B*")[0] # timestanp 
		#p pkt[8..11].unpack("B*")[0] # SSRC
		#p pkt[12..13].unpack("B*")[0] # 拡張ヘッダのVersion
		#p pkt[14..15].unpack("B*")[0] # 拡張ヘッダのlength
		
		@@parser.parse pkt

		#for i in 0..pkt.size
		#	j = i+1
		#	b = pkt[i..j].unpack("B*")[0] # SSRC
		#	#p b
		#	if b == "1111111111011000" # FFD8
		#		p "start"
		#		@@jpeg = 1
		#	end
		#	if @@jpeg == 1
		#	#	p b
		#	end
		#	if b == "1111111111011001" # FFD9
		#		#p "end"
		#		#exit 1
		#	end
		#end

		#p pkt
		#p pkt.unpack("N*").pack("V*").unpack("B*")
		#exit 1
	end
end
