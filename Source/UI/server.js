var app = require('express.io')(),
	express = require('express'),
	http = require('http'),
	fs = require('fs'),
	request = require('request'),
	bodyParser = require('body-parser'),
	logger = require('log4js').getLogger(),
	time = require('time'),
	time_now = new time.Date(),
	SerialPort = require("serialport").SerialPort,
	serialPort = new SerialPort("/dev/tty.usbmodemfd131", {
		baudrate: 115200
	});


// App config
app.http().io()
app.set('port', process.env.PORT || 3000);
app.use(bodyParser.urlencoded({
	extended: true
}));
app.use(express.static(__dirname, '/public'));


//WebRoot
app.get('/', function(req, res) {
	logger.info('Smart Green House UI is started');
});

//Socket Root for Serial Port
app.io.route('serial', function(req) {
	serialPort.open(function() {
		logger.info('Serial Port is opened');						
		serialPort.on('data', function(data) {
			req.io.emit('logs', {
				message: time_now.toString() + ':' + data
			})
		});
	});
});

//Server 
var server = app.listen(app.get('port'), function() {
	logger.info('Smart Green House App is running on %d', app.get('port'));
});
