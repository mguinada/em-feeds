$(function() {
    var chart_options = {
        chart: {
            renderTo: 'chart',
            defaultSeriesType: 'spline',
            marginRight: 10,
            events: {
                /*
                load: function() {
                    // set up the updating of the chart each second
                    var series = this.series[0];
                    setInterval(function() {
                        var x = (new Date()).getTime(), // current time
                            y = Math.random();
                        series.addPoint([x, y], true, true);
                    }, 1000);
                }
                */
                /*
                load: function() {
                    // set up the updating of the chart each second
                    setInterval(function() {
                        var series_data = chart_options.series[0].data;
                        //alert(series_data.length);
                        for(var i = 0; i < series_data.length; i++) {
                            //log("t: " + series_data[i].x + " qty: " + series_data[i].y);
                            chart.series[0].addPoint([series_data[i].x * 1000, series_data[i].y], true, true);
                        }
                    }, 1000);
                }*/
            }
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
        tooltip: {
            formatter: function() {
                    return '<b>'+ this.series.name +'</b><br/>'+
                    Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) +'<br/>'+
                    Highcharts.numberFormat(this.y, 2);
            }
        },
        legend: {
            enabled: false
        },
        series: [{
            name: 'Tweet / t',
            data: []
        }]
    };

    var chart = new Highcharts.Chart(chart_options);

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
       //log("STATS: t=" + payload.stats[0].time + " qty=" + payload.stats[0].quantity);
       var tweet_data = [];
       //for(var i = 0; i < payload.stats.length && i < 100; i++) {
       for(var i = payload.stats.length - 1; i > 0 && i > payload.stats.length - 100; i--) {
         tweet_data.push({
             x: new Date(payload.stats[i].time).getTime(),
             y: payload.stats[i].quantity
         });
       }
       chart.series[0].data = tweet_data;
       chart.redraw();
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



    /*function buildXAxis() {
        var axis_values = [];

        for(var i = 0; i < 60; i++) {
            axis_values.push("" + pad(i, 1) + "m");
        }

        return axis_values;
    }*/
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


/*
VER: http://www.highcharts.com/demo/
var chart = new Highcharts.Chart({
    chart: { renderTo: 'chart',
             defaultSeriesType: 'line',
             marginRight: 130,
             marginBottom: 25
    },
    title: {
        text: "Tweet Graph"
    },
    xAxis: {
        categories: buildXAxis()
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
    legend: { style: 'none' },
    series: [{
            name: 'Tokyo',
            data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
        }, {
            name: 'New York',
            data: [-0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
        }, {
            name: 'Berlin',
            data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
        }, {
            name: 'London',
            data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
        }]
});
*/