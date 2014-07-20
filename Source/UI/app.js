require.config({
    baseUrl: 'lib',
    paths: {
        app: '../script',
		socketio: '/socket.io/socket.io.js',
        moment: 'moment'
    }
});

require(['app/main']);
