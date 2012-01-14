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

var Presenter = function() {
    this.tweet_dom_nodes = [];
    this.time_chart = new Highcharts.Chart(time_chart_options);
    this.term_hit_chart = new Highcharts.Chart(term_hit_chart_options);
};

Presenter.prototype.showTweet = function(payload) {
    var tweets_view = $('div#tweets');
    var tweet_view = $("<div id='tweet' style='display: none;'></div>");
    var user_html = $("<div class='grid_4'><b>@" + payload.handle + "</b></div>");
    var tweet_html = $("<div class='grid_9'>" + payload.tweet + "</div>");

    tweet_view.append(user_html);
    tweet_view.append(tweet_html);

    tweet_view.append($("<div class='clear'>&nbsp;</div>"));
    tweets_view.append(tweet_view);
    this.tweet_dom_nodes.push(tweet_view);

    //Don't let the DOM transform into a monster
    if(this.tweet_dom_nodes.length >= 20) {
        this.tweet_dom_nodes.shift().remove();
    }

    tweet_view.slideDown(100);
    tweets_view.animate({scrollTop: $('div#tweet').length * 30}, 800);
};

Presenter.prototype.traceTweetVsTimeGraph = function(payload) {
    var tweet_vs_time = [];
    for (var i = 0; i < payload.stats.tweets_vs_time.length; i++) {
        tweet_vs_time.push({
            x: new Date(payload.stats.tweets_vs_time[i].time).getTime(),
            y: payload.stats.tweets_vs_time[i].quantity
        });
    }
    this.time_chart.get("tweet_time_series").setData(tweet_vs_time, true);
};

Presenter.prototype.traceTermHitCountGraph = function(payload) {
    var terms = [];
    var term_hits = [];
    for (var j = 0; j < payload.stats.term_hits.length; j++) {
        terms.push(payload.stats.term_hits[j].term);
        term_hits.push(payload.stats.term_hits[j].quantity);
    }
    this.term_hit_chart.xAxis[0].setCategories(terms, true);
    this.term_hit_chart.get("tweet_term_hit_series").setData(term_hits, true);
};

Presenter.prototype.displayAuthFailedError = function() {
    $('#auth_failure').overlay({ load: true, closeOnClick: false, closeOnEsc: false });
};

Presenter.prototype.show = function(message) {
    var payload = JSON.parse(message.data);
    this.showTweet(payload);
    this.traceTweetVsTimeGraph(payload);
    this.traceTermHitCountGraph(payload);
};
