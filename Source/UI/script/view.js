define(['socketio', 'moment', 'app/util'], function (socket, moment, util) {

    return {
        init: function () {
            socket = socket.connect()
            this.initSaveButton()
            this.initSensorValues()
            this.initProgBar()
            this.initSliders()
            this.initSerialPortList()
        },

        initSerialPortList: function () {
            $("#serialPortList").selectmenu();
            $("#serialPortList").on("selectmenuchange", function (event, ui) {
                if (ui.item.value != 'title') {
                    socket.emit('server', {
                        command: 'serialSet',
                        port: ui.item.label
                    })
                    setTimeout(function () {
                        socket.emit('server', {
                            command: 'getCurrentData'
                        })
                    }, 2000)
                }
            });
        },

        initSaveButton: function () {
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
        },

        initSensorValues: function () {
            $('#temperature').text('00')
            $('#moisture').text('00')
            $('#humidity').text('00')
            $('#luminosity').text('00')
        },

        initProgBar: function () {
            $('#pumpBar').css('width', '100%')
            $('#pump').text('Pump is switched on at 2014-07-20 12:14:57 for 300 Seconds')
            $('#lightBar').css('width', '100%')
            $('#light').text('Light is switched on at 2014-07-20 12:14:57 for 300 Seconds')
        },

        initSliders: function () {
            $("#temperaturerange").slider({
                range: true,
                min: 0,
                max: 50,
                values: [ 0, 50 ],
                slide: function () {
                    var temp = $('#temperaturerange').slider("values")
                    temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
                    $("#temperaturerange .ui-slider-range").html(temp)
                }
            });

            $("#humidityrange").slider({
                range: true,
                min: 20,
                max: 90,
                values: [ 20, 90 ],
                slide: function () {
                    var temp = $('#humidityrange').slider("values")
                    temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
                    $("#humidityrange .ui-slider-range").html(temp)
                }
            });

            $("#luminosityrange").slider({
                range: true,
                min: 0,
                max: 40000,
                values: [ 0, 40000 ],
                slide: function () {
                    var temp = $('#luminosityrange').slider("values")
                    temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
                    $("#luminosityrange .ui-slider-range").html(temp)
                }
            });

            $("#soilrange").slider({
                range: true,
                min: 0,
                max: 1023,
                values: [ 0, 1023 ],
                slide: function () {
                    var temp = $('#soilrange').slider("values")
                    temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
                    $("#soilrange .ui-slider-range").html(temp)
                }
            });
        },

        updateSerialPorts: function (ports) {
            var template = ''
            $.each(ports, function (key, value) {
                template = '<option>' + value.comName + '</option>'
                $('#serialPortList').append(template)
            })
        },

        updateSensor: function (message, time) {
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
        },

        updateRange: function (message, time) {
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

                this.updateRangeText()
            }
        },

        updateActuator: function (message, time) {
            var actuatorType = message[0];
            var template;
            var startTime = moment(time).diff(parseInt(message[1]))
            var endTime = moment(time).add(parseInt(message[2]))

            var timeSpan = moment(endTime).diff(moment(startTime), 'seconds');

            switch (actuatorType) {
                case '1':
                    template = '<p>[' + time + '] [Actuator] Pump is on for ' + timeSpan + ' seconds </p>';
                    $('#serialLog').prepend(template)
                    this.updatePumpProgressBar(startTime, endTime)
                    break;

                case '2':
                    template = '<p>[' + time + '] [Actuator] Light is on for ' + timeSpan + ' seconds </p>';
                    $('#serialLog').prepend(template)
                    this.updateLightProgressBar(startTime, endTime)
                    break;
            }
        },

        updatePumpProgressBar: function (startTime, endTime) {
            var timer = setInterval(barTimer, 1000)

            function barTimer() {
                var barSize = util.calculateBar(startTime, endTime)
                var timeSpan = moment(endTime).diff(moment(startTime), 'seconds')

                if (barSize >= 0 && barSize < 101) {
                    if (barSize > 100) {
                        barSize = 100
                    }
                    $('#pumpBar').parent().addClass("active")
                    $('#pumpBar').css('width', barSize + '%')
                    var temp = 'Pump is switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + ' Seconds'
                    $('#pump').text(temp)

                } else {
                    $('#pumpBar').parent().removeClass("active")
                    var temp = 'Pump was last switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + ' Seconds'
                    $('#pump').text(temp)
                    clearTimer()
                }
            }

            function clearTimer() {
                console.log('Pump timer cleared')
                clearInterval(timer)
            }
        },

        updateLightProgressBar: function (startTime, endTime) {
            var timer = setInterval(barTimer, 1000)

            function barTimer() {
                var barSize = util.calculateBar(startTime, endTime)
                var timeSpan = moment(endTime).diff(moment(startTime), 'seconds')

                if (barSize >= 0 && barSize < 101) {
                    if (barSize > 100) {
                        barSize = 100
                    }
                    $('#lightBar').parent().addClass("active")
                    $('#lightBar').css('width', barSize + '%')
                    var temp = 'Light is switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + ' Seconds'
                    $('#light').text(temp)

                } else {
                    $('#lightBar').parent().removeClass("active")
                    var temp = 'Light was last switched on at ' + moment(startTime).format("YYYY-MM-DD HH:mm:ss") + ' for ' + timeSpan + ' Seconds'
                    $('#light').text(temp)
                    clearTimer()
                }
            }

            function clearTimer() {
                console.log('Light timer cleared')
                clearInterval(timer)
            }
        },

        updateRangeText: function () {
            var temp = $('#temperaturerange').slider("values")
            temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
            $("#temperaturerange .ui-slider-range").html(temp)

            temp = $('#humidityrange').slider("values")
            temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
            $("#humidityrange .ui-slider-range").html(temp)

            temp = $('#luminosityrange').slider("values")
            temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
            $("#luminosityrange .ui-slider-range").html(temp)

            temp = $('#soilrange').slider("values")
            temp = "<div class='sliderText'>" + temp[0] + ' - ' + temp[1] + "</div>"
            $("#soilrange .ui-slider-range").html(temp)
        }



    };
});
