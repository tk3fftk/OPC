#encoding: utf-8

require 'net/http'
require 'socket'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'thin'
require 'em-websocket'
require 'rtp'

require './opc_udp'

# sinatra設定
configure do
  set :environment, :production # デフォルトでは外部からsinatraにアクセスできない
end


EventMachine.run do
  class OPC_service < Sinatra::Application
		# params
		# カメラモードを変更
		@@switch_cameramode = "/switch_cameramode.cgi?mode="
		# 撮影開始
		@@exec_takemotion = "/exec_takemotion.cgi?com=newstarttake"#&point=0600x0200"
		# 電源OFF
		@@exec_pwoff = "/exec_pwoff.cgi"
		# コマンド受付方法の取得
		@@get_commpath = "/get_commpath.cgi"
		# 状態の取得
		@@get_state = "/get_state.cgi"
		# カメライベント通知開始
		@@start_pushevent = "/start_pushevent.cgi?port=65000"
		# カメライベント通知終了
		@@start_pushevent = "/stop_pushevent.cgi?port=65000"
		# カメラプロパティ取得 ディスクリプタ
		@@get_camprop_desc = "/get_camprop.cgi?com=desc&propname="
		# カメラプロパティ設定
		@@set_camprop = "/set_camprop.cgi?com=set&propname="
		# 画像リスト取得
		@@get_imglist = "/get_imglist.cgi?DIR=/DCIM/100OLYMP"
		# 画像取得
		@@get_screennail = "get_screennail.cgi?DIR=/DCIM/100OLYMP/"
		# 接続モード取得
		@@get_connectmode = "/get_connectmode.cgi"
		# レンズズーム
		@@exec_misc_zoom_start_tele = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=start&dir=tele&method=contslow"
		@@exec_misc_zoom_start_wide = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=start&dir=wide&method=contslow"
		@@exec_misc_zoom_stop = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=stop"
		# ライブビュー
		@@exec_misc_start_liveivew = "/exec_takemisc.cgi?com=startliveview&port=5555"
		@@exec_misc_stop_liveivew = "/exec_takemisc.cgi?com=stopliveview"

		# イベント通知ポートOPEN
		#event_socket = TCPSocket.open("192.168.0.10", 65000)

		# カメラの状態取得 将来的にはインタフェースにしたい
		get '/' do
			erb :index
		end

		# カメラモード変更
		get '/switch_cameramode/:mode' do
		  content_type 'text/xml'
		  url = @@switch_cameramode + params['mode']
		  exec_get_command(url).body
		end

		# 電源OFF
		get '/pwoff' do
		  content_type 'text/xml'
		  exec_get_command(@@exec_pwoff).body
		end

		# TCPカメライベント通知開始 ポートは65000
		get '/start_pushevent' do
		  content_type 'text/xml'
		  exec_get_command(@@start_pushevent).body
		end

		# TCPカメライベント通知開始 ポートは65000
		get '/stop_pushevent' do
		  content_type 'text/xml'
		  exec_get_command(@@stop_pushevent).body
		end

		# カメラの状態取得
		get '/get_state' do
		  content_type 'text/xml'
		  exec_get_command(@@get_state).body
		end

		# カメラプロパティ ディスクリプタ 取得
		get '/get_camprop/:propname' do
		  content_type 'text/xml'
		  url = @@get_camprop_desc + params['propname']
		  exec_get_command(url).body
		end

		# カメラプロパティ設定
		get '/set_camprop/:propname/:value' do
		  content_type 'text/xml'
		  url = @@set_camprop + params['propname']
		  body = {"set" => {"value" => params['value']}}
		  puts body
		  exec_post_command(url, body).body
		end

		# 画像リスト取得
		get '/get_imglist' do
		  content_type 'text/plain'
		  exec_get_command(@@get_imglist).body
		end

		# デバイス表示用画像取得 TODO
		get '/get_screennail/:filename' do
		  content_type 'image/jpeg'
		  url = @@get_screennail + params['filename']
		  puts url
		  exec_get_command(url).body
		end

		# 画像取得
		get '/get_img/:filename' do
		  content_type 'image/jpeg'
		  url = "/DCIM/100OLYMP/" + params['filename'] + ".JPG"
		  puts url
		  exec_get_command(url).body
		end

		# ライブビュー開始
		get '/start_liveview' do
		  content_type 'text/xml'
		  exec_get_command(@@exec_misc_start_liveivew).body
		end

		# ライブビュー終了
		get '/stop_liveview' do
		  content_type 'text/xml'
		  exec_get_command(@@exec_misc_stop_liveivew).body
		end

		# 撮影
		get '/takemotion' do
		  content_type 'text/xml'
		  exec_get_command(@@exec_takemotion).body
		end

		# コマンド実行 get
		def exec_get_command(command)
		  host = "http://192.168.0.10"
		  user_agent= "OlympusCameraKit"
			header = {
				"User-Agent" => user_agent
			}
			uri = URI("#{host}#{command}")
			http = Net::HTTP.new(uri.host, uri.port)
			return http.get(uri.request_uri, header)
		end

		# コマンド実行 post
		def exec_post_command(command, body)
		  host = "http://192.168.0.10"
		  user_agent= "OlympusCameraKit"
			header = {
				"User-Agent" => user_agent
			}
			uri = URI("#{host}#{command}")

		  return Net::HTTP.post_form(uri, body)
		end
	end

	UdpServer.run

	OPC_service.run! :port => 4567 if "opc_service.rb" == $0
end
