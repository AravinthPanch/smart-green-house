define(function (require) {
    var socket = require('socketio');
    var moment = require('moment')
    socket = socket.connect()

    socket.on('client', function (socket) {
        var message = socket.data.packet
        var time = socket.data.time

        if (message.indexOf('SENSOR') >= 0) {
            message = message.match("SENSOR:(.*)")[1]
            message = message.split(":")
            updateSensor(message, time)
        }
        else if (message.indexOf('ACTUATOR') >= 0) {
            message = message.match("ACTUATOR:(.*)")[1]
            message = message.split(":")
            updateActuator(message, time)
        }
        else if (message.indexOf('RANGE') >= 0) {
            message = message.match("RANGE:(.*)")[1]
            message = message.split(":")
            updateRange(message, time)
        }
    })

    socket.emit('server', {
        command: 'init'
    })

    function updateSensor(message, time) {
        var sensorType = message[0];
        var template;
        var sensorValue = message[1];

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
        var template;

        if (message.length == 8) {
            $("#temperaturerange").slider("values", [ message[0], message[1] ])
            $("#humidityrange").slider("values", [ message[2], message[3] ])
            $("#luminosityrange").slider("values", [ message[4], message[5] ])
            $("#soilrange").slider("values", [ message[6], message[7] ])

            template = '<p>[' + time + '] [Sensor] Air Temperature range is [ ' + message[0] + ' : ' + message[1] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Humidity range is [ ' + message[2] + ' : ' + message[3] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Luminosity range is [ ' + message[4] + ' : ' + message[5] + ' ]</p>';
            $('#serialLog').prepend(template)
            template = '<p>[' + time + '] [Sensor] Soil Moisture range is [ ' + message[6] + ' : ' + message[7] + ' ]</p>';
            $('#serialLog').prepend(template)
        }
    }

    function updateActuator(message, time) {
        var actuatorType = message[0];
        var template;
        var startTime = parseInt(message[1])
        var endTime = parseInt(message[2])
        var timeSpan = moment(endTime).diff(moment(startTime), 'seconds')

        switch (actuatorType) {
            case '1':
                template = '<p>[' + time + '] [Actuator] Pump is on for ' + timeSpan + ' seconds </p>';
                $('#serialLog').prepend(template)
                updatePumpProgressBar(startTime, endTime)
                break;

            case '2':
                template = '<p>[' + time + '] [Actuator] Light is on for ' + timeSpan + ' seconds </p>';
                $('#serialLog').prepend(template)
                updateLightProgressBar(startTime, endTime)
                break;
        }
    }

    function updatePumpProgressBar(startTime, endTime) {
        var timer = setInterval(barTimer, 1000)

        function barTimer() {
            var barSize = calculateBar(startTime, endTime)
            var timeSpan = moment(endTime).diff(moment(startTime), 'seconds')

            if (barSize >= 0 && barSize <= 100) {
                $('#pumpBar').addClass("active")
                $('#pumpBar').css('width', barSize + '%')
                var temp = 'Pump is switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + ' Seconds'
                $('#pump').text(temp)
            } else {
                $('#pumpBar').removeClass("active")
                clearTimer()
            }
        }

        function clearTimer() {
            console.log('Pump timer cleared')
            clearInterval(timer)
        }
    }

    function updateLightProgressBar(startTime, endTime) {
        var timer = setInterval(barTimer, 1000)

        function barTimer() {
            var barSize = calculateBar(startTime, endTime)
            var timeSpan = moment(endTime).diff(moment(startTime), 'seconds')

            if (barSize >= 0 && barSize <= 100) {
                $('#lightBar').addClass("active")
                $('#lightBar').css('width', barSize + '%')
                var temp = 'Light is switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + 'Seconds'
                $('#light').text(temp)
            } else {
                $('#lightBar').removeClass("active")
                clearTimer()
            }
        }

        function clearTimer() {
            console.log('Light timer cleared')
            clearInterval(timer)
        }
    }


    function calculateBar(startTime, endTime) {
        var timeSpan = endTime - startTime
        var currentTime = Date.now()
        var completedTime = moment(currentTime).diff(startTime)
        var barSize = (completedTime / timeSpan) * 100
        return barSize
    }

    function initView() {
        $('#saveButton').click(function () {
            socket.emit('server', {
                command: 'setSensorRange',
                value: {
                    S1: $("#temperaturerange").slider("values"),
                    S2: $("#humidityrange").slider("values"),
                    S3: $("#luminosityrange").slider("values"),
                    S4: $("#soilrange").slider("values")
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


