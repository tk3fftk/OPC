# encoding: utf-8

class RTPParser
	# JPEGサブフレームを貯める
	@@jpeg = []

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
			#JPEGサブフレームの処理
		# 最後のパケット
		elsif hash[:M] == "1"
			p @@jpeg.pack('m')
			@@jpeg = []
		# 途中パケット
		else
			# 残りパケットを@@jpegに追加
			@@jpeg.push(pkt[12..-1])
		end
	end
end
