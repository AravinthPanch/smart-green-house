var app = require('express.io')(),
	express = require('express'),
	http = require('http'),
	fs = require('fs'),
	request = require('request'),
	bodyParser = require('body-parser'),
	logger = require('log4js').getLogger(),
	moment = require('moment'),	
	SerialPort = require("serialport").SerialPort,
	serialPort = new SerialPort("/dev/tty.usbmodemfd131", {
		baudrate: 38400
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
	logger.info('UI is started');
});

//Socket Root for Serial Port
app.io.route('serial', function(req) {
	serialPort.open(function() {
		logger.info('Serial Port is opened');
		serialPort.on('data', function(data) {
			var timestamp = moment(new Date().getTime()).format("YYYY-MM-DD HH:mm:ss.SSS");
			req.io.emit('logs', {
				message: '[' + timestamp.toString("%A") + '] [Serial]' + ' - ' + data
			})
		});
	});
});

//Server 
var server = app.listen(app.get('port'), function() {
	logger.info('Server is started');
	logger.info('Port is openened at http://localhost:%d', app.get('port'));
});
