var win = Ti.UI.createWindow();
var SIO = require('com.bongole.ti.socketio');
var s = SIO.createSocket();

s.addEventListener('connect', function(e){
    alert('connect');
})

s.addEventListener('receiveEvent', function(e){
    alert(e.name);
    alert(e.args);
});

s.addEventListener('receiveMessage', function(e){
    alert(e.data);
});

s.addEventListener('error', function(e){
    alert(e);
});

var b = Ti.UI.createButton({
    title: 'push'
})

b.addEventListener('click', function(e){
    s.connect('http://localhost:4000', { a: 1, b: 2 });
});

var b2 = Ti.UI.createButton({
    title: 'push',
    top: 0
})

b2.addEventListener('click', function(e){
    s.sendEvent('test', 'HOGEHOGE!!!!');
});

win.add(b2);

win.add(b);

win.open();
