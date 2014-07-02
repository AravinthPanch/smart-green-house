require.config({
    baseUrl: 'lib',
    paths: {
        app: '../app',
		socketio: '/socket.io/socket.io.js'
    }
});

require(['app/main']);
