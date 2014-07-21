define(['socketio', 'app/view'], function (socket, view) {
    socket = socket.connect()

    socket.on('portList', function(data){
        view.updateSerialPorts(data.ports)
    })

    socket.on('client', function (socket) {
        var message = socket.data.packet
        var time = socket.data.time

        if (message.indexOf('SENSOR') >= 0) {
            message = message.match("SENSOR:(.*)")[1]
            message = message.split(":")
            view.updateSensor(message, time)
        }
        else if (message.indexOf('ACTUATOR') >= 0) {
            message = message.match("ACTUATOR:(.*)")[1]
            message = message.split(":")
            view.updateActuator(message, time)
        }
        else if (message.indexOf('RANGE') >= 0) {
            message = message.match("RANGE:(.*)")[1]
            message = message.split(":")
            view.updateRange(message, time)
        }
    })

    /*Initiate the View*/
    view.init()

    /*Initiate the App*/
    socket.emit('server', {
        command: 'init'
    })

})



