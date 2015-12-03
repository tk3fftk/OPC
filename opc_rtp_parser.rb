# encoding: utf-8
require 'faye/websocket'
require 'eventmachine'

class RTPParser
	# JPEG�T�u�t���[���𒙂߂�
	@@jpeg = []

	def initialize
		@ws = nil
	end

	def connect
		# websocket�R�l�N�V����
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

	# RTP�p�P�b�g���p�[�X���� 
	def parse pkt
		# RTP�w�b�_
		# pkt[x]������8bit�����Ă���
		hash = {
			:V =>pkt[0].unpack("B*")[0][0..1], # Version
			:P =>pkt[0].unpack("B*")[0][2], # Padding
			:X =>pkt[0].unpack("B*")[0][3], # eXtension: �g���w�b�_������ꍇ��1
			:CC =>pkt[0].unpack("B*")[0][4..7], # Contributing source Count
			:M =>pkt[1].unpack("B*")[0][0], # Marker: jpeg�y�C���[�h�̍Ō�̂�1
			:PT =>pkt[1].unpack("B*")[0][1..7], # PayloadType
			:sequence_number =>pkt[2..3].unpack("B*")[0], 
			:timestamp =>pkt[4..7].unpack("B*")[0],
			:SSRC =>pkt[8..11].unpack("B*")[0] # ���M�����ʎq
		}
		# JPEG�t���[���̐擪�p�P�b�g �g���w�b�_������
		if hash[:X] == "1"
			#�g���w�b�_�̏���
			#TODO �Ƃ肠�����g���w�b�_�͖�������
			for i in 12..pkt.size
				j = i+1
				b = pkt[i..j].unpack("B*")[0] #16bit���`�F�b�N
				if b == "1111111111011000" # FFD8
					# �w�b�_���������p�P�b�g(==JPEG�T�u�t���[��)�𐶃o�C�i����@@jpeg�ɒǉ�
					@@jpeg.push(pkt[i..-1])
					break
				end
			end
		# �Ō�̃p�P�b�g�Ȃ��websocket�ɓ�����
		elsif hash[:M] == "1"
			@@jpeg.push(pkt[12..-1])
			base = Base64.strict_encode64(@@jpeg.join(""))
			@@jpeg = []
			connect if @ws.nil?
			@ws.send base
		# �r���p�P�b�g
		else
			# �w�b�_���������p�P�b�g(==JPEG�T�u�t���[��)�𐶃o�C�i����@@jpeg�ɒǉ�
			@@jpeg.push(pkt[12..-1])
		end
	end
end
