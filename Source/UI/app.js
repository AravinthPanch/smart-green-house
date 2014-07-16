require.config({
    baseUrl: 'lib',
    paths: {
        app: '../script',
		socketio: '/socket.io/socket.io.js'
    }
});

require(['app/main']);
