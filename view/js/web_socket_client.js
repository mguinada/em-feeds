$(function() {
    var socket = new WebSocket('ws://0.0.0.0:8080/');

    socket.onopen = function() {
        log('Socket opened');
    };

    socket.onclose = function() {
        log('Socket closed');
    };

    socket.onerror = function() {
        log('ERROR');
    };

    socket.onmessage = function(data) {
       log('Received data: ' + data);
    };

    var tweet_view = $('#tweets')
});

function log(msg) {
    if (window.console) console.log(msg);
}