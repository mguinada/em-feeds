$(function() {
    var time_chart_options = {
        chart: {
            renderTo: 'tweet_time_chart',
            defaultSeriesType: 'spline',
            marginRight: 10
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

    var tweet_time_chart = new Highcharts.Chart(time_chart_options);

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

       var tweet_vs_time = [];
       for(var i = 0; i < payload.stats.tweets_vs_time.length; i++) {
         tweet_vs_time.push({
             x: new Date(payload.stats.tweets_vs_time[i].time).getTime(),
             y: payload.stats.tweets_vs_time[i].quantity
         });
       }

       tweet_time_chart.get("tweet_time_series").setData(tweet_vs_time, true);

/*
       var term_hits = [];
        alert('sads');
        log(payload.stats.term_hits.length);
        alert('sads');
       for(var i = 0; i < payload.stats.term_hits.length; i++) {
           term_hits.push({
               x: payload.stats.term_hits[i].term,
               y: payload.stats.term_hits[i].quantity
           });
           log(payload.stats.term_hits[i].term + ": " + payload.stats.term_hits[i].quantity);
       }
       */
    };

    function writeTweet(user, tweet, lang) {
        var tweets_view = $('div#tweets');
        var tweet_view = $("<div id='tweet' style='display: none;'></div>");
        var user_html = $("<div class='grid_4'><b>@" + user + "</b></div>");
        var tweet_html = $("<div class='grid_9'>" + tweet + "</div>");
        var lang_html = $("<div class='grid_4'><i>[" + lang + "]</i></div>");

        tweet_view.append(user_html);
        tweet_view.append(tweet_html);
        if(lang) {
          tweet_view.append(lang_html);
        }

        tweet_view.append($("<div class='clear'>&nbsp;</div>"));
        tweets_view.append(tweet_view);

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