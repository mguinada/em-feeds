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

    socket.onmessage = function(message) {
       var payload = JSON.parse(message.data);
       writeTweet(payload.user, payload.tweet, payload.lang);
    };

    function writeTweet(user, tweet, lang) {
        var tweets_view = $('div#tweets');
        var tweet_view = $("<div id='tweet' style='display: none;'></div>");
        var user_html = $("<div class='grid_4'><b>@" + user + "</b></div>");
        var tweet_html = $("<div class='grid_8'>" + tweet + "</div>");
        var lang_html = $("<div class='grid_4'><i>[" + lang + "]</i></div>");

        tweet_view.append(user_html);
        tweet_view.append(tweet_html);
        if(lang) {
          tweet_view.append(lang_html);
        }

        tweet_view.append($("<div class='clear'>&nbsp;</div>"));
        tweets_view.append(tweet_view);

        tweet_view.slideDown(100);
        $('html, body').animate({scrollTop: tweets_view.height()}, 800);
    }
});

function log(msg) {
    if (window.console) console.log(msg);
}

