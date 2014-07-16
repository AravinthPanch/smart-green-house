define(function (require) {
    var socket = require('socketio');
    socket = socket.connect()

    socket.on('client', function (socket) {
        var message = socket.data.packet
        var time = socket.data.time

        if (message.indexOf('SENSOR') >= 0) {
            message = message.match("SENSOR:(.*)")[1]
            updateSensor(message, time)
        }
        else if (message.indexOf('ACTUATOR') >= 0) {
            message = message.match("ACTUATOR:(.*)")[1]
            console.log(message)
        }
        else if (message.indexOf('RANGE') >= 0) {
            message = message.match("RANGE:(.*)")[1]
            updateRange(message, time)
        }
    })

    socket.emit('server', {
        command: 'init'
    })

    function updateSensor(message, time) {
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


    function updateRange(message, time) {
        message = message.split(":")
        var template;

        if (message.length == 8) {
            $("#temperaturerange").slider("values", [ message[0], message[1] ])
            $("#humidityrange").slider("values", [ message[2], message[3] ])
            $("#luminosityrange").slider("values", [ message[4], message[5] ])
            $("#soilrange").slider("values", [ message[6], message[7] ])

            template = '<p>[' + time + '] [Sensor] Air Temperature range [ ' + message[0] + ' : ' + message[1] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Humidity range [ ' + message[2] + ' : ' + message[3] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Luminosity range [ ' + message[4] + ' : ' + message[5] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Soil Moisture range [ ' + message[6] + ' : ' + message[7] + ' ]</p>';
            $('#serialLog').prepend(template)
        }
    }

    function initView() {
        $('#saveButton').click(function () {
            socket.emit('server', {
                command: 'setSensorRange',
                value: {
                    S1: 55,
                    S2: 65,
                    S3: 75,
                    S4: 85
                }
            })
        })

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

    initView()
});


