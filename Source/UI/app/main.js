define(function (require) {	
	var io = require('socketio');
	
    $( "#soilrange" ).slider({
      range: true,
      min: 0,
      max: 500,
      values: [ 75, 300 ],
    });
	
    $( "#temperaturerange" ).slider({
      range: true,
      min: 0,
      max: 500,
      values: [ 75, 300 ],
    });
	
    $( "#humidityrange" ).slider({
      range: true,
      min: 0,
      max: 500,
      values: [ 75, 300 ],
    });
	
    $( "#luminosityrange" ).slider({
      range: true,
      min: 0,
      max: 500,
      values: [ 75, 300 ],
    });
	
	io = io.connect()
	io.emit('serial') 
	io.on('logs', function(data) {
		var template = '<p>' + data.message + '</p>';
		$('#serialLog').prepend(template)
	})  
});
