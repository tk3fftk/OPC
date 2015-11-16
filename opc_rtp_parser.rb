# encoding: utf-8
require 'websocket-client-simple'

class RTPParser
	# JPEG�T�u�t���[���𒙂߂�
	@@jpeg = []

	def initialize
		@ws = nil
	end

	def connect
		# websocket�R�l�N�V����
		@ws = WebSocket::Client::Simple.connect 'ws://localhost:3001'
	end

	def parse pkt
		# RTP�p�P�b�g���p�[�X���� 
		# RTP�w�b�_
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
		# �擪�p�P�b�g
		if hash[:X] == "1"
			#�g���w�b�_�̏���
			#TODO �Ƃ肠�����g���w�b�_���X�L�b�v����
			for i in 12..pkt.size
				j = i+1
				b = pkt[i..j].unpack("B*")[0] #16bit���`�F�b�N
				if b == "1111111111011000" # FFD8
					# �w�b�_���������p�P�b�g(==JPEG�T�u�t���[��)�𐶃o�C�i����@@jpeg�ɒǉ�
					@@jpeg.push(pkt[i..-1])
					break
				end
			end
		# �Ō�̃p�P�b�g
		elsif hash[:M] == "1"
			@@jpeg.push(pkt[12..-1])
			base = Base64.strict_encode64(@@jpeg.join(""))
			@@jpeg = []
			connect if @ws.nil?
			@ws.send base
			#File.write("test.txt", base)
		# �r���p�P�b�g
		else
			# �w�b�_���������p�P�b�g(==JPEG�T�u�t���[��)�𐶃o�C�i����@@jpeg�ɒǉ�
			@@jpeg.push(pkt[12..-1])
		end
	end
end
