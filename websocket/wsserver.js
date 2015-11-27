var WebSocketServer = require('ws').Server
    , http = require('http')
    , express = require('express')
    , app = express();
 
app.use(express.static(__dirname + '/'));
var server = http.createServer(app);
var wss = new WebSocketServer({server:server});
 
//Websocket�ڑ���ۑ����Ă���
var connections = [];
 
//�ڑ���
wss.on('connection', function (ws) {
    //�z���WebSocket�ڑ���ۑ�
    connections.push(ws);
    //�ؒf��
    ws.on('close', function () {
        connections = connections.filter(function (conn, i) {
            return (conn === ws) ? false : true;
        });
    });
    //���b�Z�[�W���M��
    ws.on('message', function (message) {
        //console.log('message:', message);
        //broadcast(JSON.stringify(message));
        broadcast(message);
    });
});
 
//�u���[�h�L���X�g���s��
function broadcast(message) {
    connections.forEach(function (con, i) {
        con.send(message);
    });
};
 
server.listen(8080);
