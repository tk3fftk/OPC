# encoding: utf-8
require 'faye/websocket'
require 'eventmachine'

class RTPParser
	# JPEGサブフレームを貯める
	@@jpeg = []

	def initialize
		@ws = nil
	end

	def connect
		# websocketコネクション
		EM.run {
			@ws = Faye::WebSocket::Client.new('ws://localhost:8080', [], {
				:headers => {'User-Agent' => 'ruby'}
			})

			@ws.on :open do |event|
				p [:open]
				@ws.send('hello')
			end

			@ws.on :close do |event|
				p [:close, event.code, event.reason]
			end	
		}
	end

	# RTPパケットをパースする 
	def parse pkt
		# RTPヘッダ
		# pkt[x]あたり8bit入っている
		hash = {
			:V =>pkt[0].unpack("B*")[0][0..1], # Version
			:P =>pkt[0].unpack("B*")[0][2], # Padding
			:X =>pkt[0].unpack("B*")[0][3], # eXtension: 拡張ヘッダがある場合は1
			:CC =>pkt[0].unpack("B*")[0][4..7], # Contributing source Count
			:M =>pkt[1].unpack("B*")[0][0], # Marker: jpegペイロードの最後のみ1
			:PT =>pkt[1].unpack("B*")[0][1..7], # PayloadType
			:sequence_number =>pkt[2..3].unpack("B*")[0], 
			:timestamp =>pkt[4..7].unpack("B*")[0],
			:SSRC =>pkt[8..11].unpack("B*")[0] # 送信元識別子
		}
		# JPEGフレームの先頭パケット 拡張ヘッダを持つ
		if hash[:X] == "1"
			#拡張ヘッダの処理
			#TODO とりあえず拡張ヘッダは無視する
			for i in 12..pkt.size
				j = i+1
				b = pkt[i..j].unpack("B*")[0] #16bitずつチェック
				if b == "1111111111011000" # FFD8
					# ヘッダを除いたパケット(==JPEGサブフレーム)を生バイナリで@@jpegに追加
					@@jpeg.push(pkt[i..-1])
					break
				end
			end
		# 最後のパケットならばwebsocketに投げる
		elsif hash[:M] == "1"
			@@jpeg.push(pkt[12..-1])
			base = Base64.strict_encode64(@@jpeg.join(""))
			@@jpeg = []
			connect if @ws.nil?
			@ws.send base
		# 途中パケット
		else
			# ヘッダを除いたパケット(==JPEGサブフレーム)を生バイナリで@@jpegに追加
			@@jpeg.push(pkt[12..-1])
		end
	end
end
