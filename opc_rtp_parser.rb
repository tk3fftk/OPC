# encoding: utf-8
require 'websocket-client-simple'

class RTPParser
	# JPEGサブフレームを貯める
	@@jpeg = []

	def initialize
		@ws = nil
	end

	def connect
		# websocketコネクション
		@ws = WebSocket::Client::Simple.connect 'ws://localhost:3001'
	end

	def parse pkt
		# RTPパケットをパースする 
		# RTPヘッダ
		hash = {
			:V =>pkt[0].unpack("B*")[0][0..1],
			:P =>pkt[0].unpack("B*")[0][2],
			:X =>pkt[0].unpack("B*")[0][3],
			:CC =>pkt[0].unpack("B*")[0][4..7],
			:M =>pkt[1].unpack("B*")[0][0],
			:PT =>pkt[1].unpack("B*")[0][1..7],
			:sequence_number =>pkt[2..3].unpack("B*")[0],
			:timestamp =>pkt[4..7].unpack("B*")[0],
			:SSRC =>pkt[8..11].unpack("B*")[0]
		}
			#:enhance =>pkt[0].unpack("B*")[0][0..1]
			#:JPEG_subframe =>0pkt[0].unpack("B*")[0][0..1]
		# 先頭パケット
		if hash[:X] == "1"
			#拡張ヘッダの処理
			#TODO とりあえず拡張ヘッダをスキップする
			for i in 12..pkt.size
				j = i+1
				b = pkt[i..j].unpack("B*")[0] #16bitずつチェック
				if b == "1111111111011000" # FFD8
					# ヘッダを除いたパケット(==JPEGサブフレーム)を生バイナリで@@jpegに追加
					@@jpeg.push(pkt[i..-1])
					break
				end
			end
		# 最後のパケット
		elsif hash[:M] == "1"
			@@jpeg.push(pkt[12..-1])
			base = Base64.strict_encode64(@@jpeg.join(""))
			@@jpeg = []
			connect if @ws.nil?
			@ws.send base
			#File.write("test.txt", base)
		# 途中パケット
		else
			# ヘッダを除いたパケット(==JPEGサブフレーム)を生バイナリで@@jpegに追加
			@@jpeg.push(pkt[12..-1])
		end
	end
end
