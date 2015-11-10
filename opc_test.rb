#encoding: utf-8

require 'net/http'
require 'socket'

HOST = "http://192.168.0.10"
USER_AGENT = "OlympusCameraKit"

# カメラを撮影モードに変更
cameramode_rec = "/switch_cameramode.cgi?mode=rec"#&lvqty=0640x0480"
# カメラをスタンドアロンモードに変更
cameramode_standalone = "/switch_cameramode.cgi?mode=standalone"
# 撮影開始
exec_takemotion = "/exec_takemotion.cgi?com=newstarttake"#&point=0600x0200"
# 電源OFF
exec_pwoff = "/exec_pwoff.cgi"
# コマンド受付方法の取得
get_commpath = "/get_commpath.cgi"
# コマンド受付方法の変更 to wifi
switch_commpath_wifi = "/switch_commpath.cgi?path=wifi"
# 状態の取得
get_state = "/get_state.cgi"
# カメライベント通知開始
start_pushevent = "/start_pushevent.cgi?port=65000"
# 接続モード取得
get_connectmode = "/get_connectmode.cgi"
# レンズズーム
exec_misc_zoom_start_tele = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=start&dir=tele&method=contslow"
exec_misc_zoom_start_wide = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=start&dir=wide&method=contslow"
exec_misc_zoom_stop = "/exec_takemisc.cgi?com=newctrlzoom&ctrl=stop"
# ライブビュー
exec_misc_start_liveivew = "/exec_takemisc.cgi?com=startliveview&port=5555"
exec_misc_stop_liveivew = "/exec_takemisc.cgi?com=stopliveview"

def exec_command(command)
	header = {
		"User-Agent" => USER_AGENT
	}
	uri = URI("#{HOST}#{command}")
	http = Net::HTTP.new(uri.host, uri.port)
	return http.get(uri.request_uri, header)
end

# ネゴシエーション
# 接続モード取得
puts exec_command(get_connectmode).body

# コマンド受付元切り替え
puts exec_command(switch_commpath_wifi)

# TCP カメライベント通知開始
puts exec_command(start_pushevent)
#server = TCPServer.new(65000)

# イベント通知ポートOPEN
socket = TCPSocket.open("192.168.0.10", 65000)

#puts socket.gets

# 動作モード切り替え スタンドアロン
puts exec_command(cameramode_standalone).body

# 動作モード切り替え 撮影モード
res = exec_command(cameramode_rec)
puts res.body

# ライブビュー開始
puts exec_command(exec_misc_start_liveivew).body

=begin
# ワイドにしてズームする
puts exec_command(exec_misc_zoom_start_wide).body
sleep 2
puts exec_command(exec_misc_zoom_start_tele).body
sleep 2
puts exec_command(exec_misc_zoom_stop).body
=end

sleep 1

# 撮影
r = exec_command(exec_takemotion)
puts r.header
puts r.body

# カメラ状態取得
puts exec_command(get_state).body

# ライブビュー停止
puts exec_command(exec_misc_stop_liveivew)

socket.close
