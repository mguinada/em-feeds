$(function() {
    var WebSocketImpl = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    var socket = new WebSocketImpl('ws://0.0.0.0:3001/');

    var presenter = new Presenter();

    socket.onopen = function() {
        socket.send($('#session_id').val());
        log('Socket opened');
    };

    socket.onclose = function() {
        log('Socket closed');
    };

    socket.onerror = function() {
        log('ERROR');
    };

    socket.onmessage = function(message) {
        switch(checkPayloadType(message)) {
           case PayloadTypes.TWITTER_DATA:
               presenter.show(message);
           break;
           case PayloadTypes.SERVER_SIDE_ERROR:
               processError(message);
           break;
           default:
               log('Unknown message type');
               alert('Fatal Error!');
       }
    };

    function checkPayloadType(message) {
        if(getErrorCode(message) != null) {
            return PayloadTypes.SERVER_SIDE_ERROR;
        } else {
            return PayloadTypes.TWITTER_DATA;
        }
    }

    function getErrorCode(message) {
        var result = message.data.match(/^ERROR#(\d+)$/);
        if(result == null) {
            return null;
        } else {
            return result[1];
        }
    }

    function processError(message) {
        if(getErrorCode(message) == "401") {
            presenter.displayAuthFailedError();
        } else {
            alert('Unknown error type');
        }
    }
    var PayloadTypes = Object.freeze({"SERVER_SIDE_ERROR": -1, "TWITTER_DATA": 0});
});

function log(msg) {
    if (window.console) console.log(msg);
}

function pad(number, length) {
    var str = '' + number;
    while (str.length < length) {
        str = '0' + str;
    }
    return str;
}