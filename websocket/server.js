var http = require('http');
var ws = require('websocket').server;

var url = require('url');

var server = http.createServer(function(request, response){
	console.log((new Date()) + ' Received request for ' + request.url);
	response.writeHead(404);
	response.end();
});
server.listen(8080, function(){
	console.log((new Date()) + ' Server is listening on port 8080');
});

wsServer = new ws({
	httpServer: server
});
var accept = ['localhost', '127.0.0.1'];

wsServer.on('request', function(request){
	console.log(request.origin);
	request.origin = request.origin || '*';
	if (accept.indexOf(url.parse(request.origin).hostname) === -1) {
		request.reject();
		console.log(request.origin + ' access not allowed.');
		return;
	}
	var connection = request.accept(null, request.origin);

	connection.on('message', function(message){
		console.log((new Date()) + ' Message Received from ' + request.origin);
		connection.sendUTF(message.utf8Data);
	});

	connection.on('close', function(reasonCode, description) {
		console.log((new Date()) + ' Peer ' + connection.remoteAddress + ' disconnected.');
	});
});
