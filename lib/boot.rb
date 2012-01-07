require 'rubygems'
require 'bundler'

Bundler.require

$:.unshift File.expand_path(File.dirname(__FILE__))
require 'ext/callbacks'
require 'twitter_stream'
require 'web_socket_server'
require 'stats_engine'
require 'channels'
require 'sinatra_app'