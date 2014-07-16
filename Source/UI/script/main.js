define(function (require) {
    var socket = require('socketio');
    socket = socket.connect()

    socket.on('client', function (socket) {
        var message = socket.data.packet
        var time = socket.data.time

        if (message.indexOf('SENSOR') >= 0) {
            message = message.match("SENSOR:(.*)")[1]
            getSensor(message, time)
        }
        else if (message.indexOf('ACTUATOR') >= 0) {
            message = message.match("ACTUATOR:(.*)")[1]
            console.log(message)
        }
    })

    socket.emit('server', {
        command: 'init'
    })

    function getSensor(message, time) {
        var sensorType = message[0];
        var template;
        var sensorValue = message.match(":(.*)")[1];

        switch (sensorType) {
            case '1':
                template = '<p>[' + time + '] [Sensor] Air Temperature is ' + sensorValue + '</p>';
                $('#serialLog').prepend(template)
                $('#temperature').empty()
                $('#temperature').append(sensorValue + ' °C')
                break;

            case '2':
                template = '<p>[' + time + '] [Sensor] Humidity is ' + sensorValue + '</p>';
                $('#serialLog').prepend(template)
                $('#humidity').empty()
                $('#humidity').append(sensorValue)
                break;

            case '3':
                template = '<p>[' + time + '] [Sensor] Luminosity is ' + sensorValue + '</p>';
                $('#serialLog').prepend(template)
                $('#luminosity').empty()
                $('#luminosity').append(sensorValue)
                break;

            case '4':
                template = '<p>[' + time + '] [Sensor] Soil Moisture is ' + sensorValue + '</p>';
                $('#serialLog').prepend(template)
                $('#moisture').empty()
                $('#moisture').append(sensorValue)
                break;
        }
    }

    function initSliders(){
        $("#soilrange").slider({
            range: true,
            min: 0,
            max: 500,
            values: [ 75, 300 ]
        });

        $("#temperaturerange").slider({
            range: true,
            min: 0,
            max: 500,
            values: [ 50, 150 ]
        });

        $("#humidityrange").slider({
            range: true,
            min: 0,
            max: 500,
            values: [ 100, 350 ]
        });

        $("#luminosityrange").slider({
            range: true,
            min: 0,
            max: 500,
            values: [ 200, 400 ]
        });
    }

    initSliders()
});


