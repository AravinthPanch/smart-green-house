define(function (require) {	
	var io = require('socketio');
	
	io = io.connect()
	io.emit('serial') 
	io.on('logs', function(data) {
		var template = '<p>' + data.message + '</p>';
		$('#serialLog').append(template)
	})  
});
