var io = require('socket.io').listen(4000);

io.sockets.on('connection', function (socket) {
    socket.emit('news', { hello: 'world' });
    socket.on('test', function (data) {
        console.log(data);
    });

    setTimeout(function(){
        socket.emit('hogehoge');
    }, 5000);
});
