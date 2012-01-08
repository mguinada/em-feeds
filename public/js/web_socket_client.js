$(function() {
    var time_chart_options = {
        chart: {
            renderTo: 'tweet_time_chart',
            defaultSeriesType: 'spline',
            marginRight: 10,
            height: 350
        },
        title: {
            text: 'Tweets / t'
        },
        xAxis: {
            type: 'datetime',
            tickPixelInterval: 150
        },
        yAxis: {
            title: {
                text: 'Tweets'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        legend: {
            enabled: false
        },
        series: [{
            id: 'tweet_time_series',
            name: 'Tweet / t',
            data: []
        }]
    };

    var term_hit_chart_options = {
        chart: {
            renderTo: 'tweet_term_hit_chart',
            defaultSeriesType: 'column',
            marginRight: 10,
            height: 350
        },
        title: {
            text: 'Term Hit Count'
        },
        xAxis: {
          text: 'terms',
          categories: []
        },
        yAxis: {
            title: {
                text: 'Count'
            }
        },
        legend: {
            enabled: false
        },
        series: [{
            id: 'tweet_term_hit_series',
            name: 'Term hit count',
            data: []
        }]
    };

    var tweet_time_chart = new Highcharts.Chart(time_chart_options);
    var term_hit_chart = new Highcharts.Chart(term_hit_chart_options);

    var WebSocketImpl = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    var socket = new WebSocketImpl('ws://0.0.0.0:3001/');

    var tweet_nodes = [];

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
                processTwitterData(message, tweet_nodes);
           break;
           case PayloadTypes.SERVER_SIDE_ERROR:
               processError(message);
           break;
           default:
               log('Unknown message type');
               alert('Fatal Error!');
       }
    };

    function processTwitterData(message, tweet_nodes) {
        var payload = JSON.parse(message.data);

        writeTweet(tweet_nodes, payload.handle, payload.tweet, payload.lang);

        var tweet_vs_time = [];
        for (var i = 0; i < payload.stats.tweets_vs_time.length; i++) {
            tweet_vs_time.push({
                x: new Date(payload.stats.tweets_vs_time[i].time).getTime(),
                y: payload.stats.tweets_vs_time[i].quantity
            });
        }

        var terms = [];
        var term_hits = [];
        for (var j = 0; j < payload.stats.term_hits.length; j++) {
            terms.push(payload.stats.term_hits[j].term);
            term_hits.push(payload.stats.term_hits[j].quantity);
        }

        tweet_time_chart.get("tweet_time_series").setData(tweet_vs_time, true);
        term_hit_chart.xAxis[0].setCategories(terms, true);
        term_hit_chart.get("tweet_term_hit_series").setData(term_hits, true);
    }

    var PayloadTypes = Object.freeze({"SERVER_SIDE_ERROR":-1, "TWITTER_DATA":0});

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
            displayAuthFailedError();
        } else {
            alert('Unknown error type');
        }
    }

    function displayAuthFailedError() {
        $('#auth_failure').overlay({ load: true, closeOnClick: false, closeOnEsc: false });
    }

    function writeTweet(tweet_dom_nodes, user, tweet, lang) {
        var tweets_view = $('div#tweets');
        var tweet_view = $("<div id='tweet' style='display: none;'></div>");
        var user_html = $("<div class='grid_4'><b>@" + user + "</b></div>");
        var tweet_html = $("<div class='grid_9'>" + tweet + "</div>");
        var lang_html = $("<div class='grid_4'><i>[" + lang + "]</i></div>");

        tweet_view.append(user_html);
        tweet_view.append(tweet_html);

        /* TODO: deprecate the language data entry */
        if(lang) {
          tweet_view.append(lang_html);
        }

        tweet_view.append($("<div class='clear'>&nbsp;</div>"));
        tweets_view.append(tweet_view);
        tweet_dom_nodes.push(tweet_view);

        //Don't let the DOM transform into a monster
        if(tweet_dom_nodes.length > 20) {
            tweet_nodes.shift().remove();
        }

        tweet_view.slideDown(100);
        tweets_view.animate({scrollTop: $('div#tweet').length * 30}, 800);
    }
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