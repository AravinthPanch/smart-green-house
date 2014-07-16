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
app.use(express.static(__dirname, '/public'));


//WebRoot
app.get('/', function (req, res) {
    logger.info('UI is started');
});


//Socket Root for Serial Port
app.io.route('server', function (socket) {
    switch (socket.data.command) {
        case 'init':
            initSerial(socket)
            break;
        case 'setSensorRange':
            setSensorRange(socket.data.value)
            break;
        case 'getSensorRange':
            getCurrentSensorRange()
            break;
    }
});

//Server
var server = app.listen(app.get('port'), function () {
    logger.info('Server is started');
    logger.info('Port is openened at http://localhost:%d', app.get('port'));
});


function initSerial(socket) {
    serialPort.open(function () {
        logger.info('Serial Port is opened');

        var buffer = '';
        serialPort.on('data', function (data) {
            buffer += data.toString();

            if (buffer.indexOf('S:') >= 0 && buffer.indexOf(':E') >= 0) {
                buffer = buffer.match("S:CC:(.*?):E")
                emitData(buffer[1], socket)
                buffer = ''
            }
        });

        getCurrentData();
    });
}


function emitData(packet, socket) {
    var timestamp = moment(new Date().getTime()).format("YYYY-MM-DD HH:mm:ss.SSS");

    var data = {
        time: timestamp.toString("%A"),
        packet: packet
    }

    socket.io.emit('client', {
        data: data
    })
}


function getCurrentData() {
    serialPort.write("S:UI:GET:DATA:E", function (err, results) {
        if (err != undefined) {
            logger.error(err)
        }
    });
}

function getCurrentSensorValue(){
    serialPort.write("S:UI:GET:VALUE:E", function (err, results) {
        if (err != undefined) {
            logger.error(err)
        }
    });
}

function getCurrentSensorRange(){
    serialPort.write("S:UI:GET:RANGE:E", function (err, results) {
        if (err != undefined) {
            logger.error(err)
        }
    });
}

function setSensorRange(value){
    var command = "S:UI:SET:RANGE:" + value.S1 + ':' + value.S2 + ':' + value.S3 + ':' + value.S4 + ':E'
    serialPort.write(command, function (err, results) {
        if (err != undefined) {
            logger.error(err)
        }
    });
}


