require 'rubygems'
require 'bundler'

Bundler.require

$:.unshift File.expand_path(File.dirname(__FILE__))
require 'callbacks'
require 'language_detector'
require 'twitter_stream'
require 'web_socket_server'
require 'stats_engine'
require 'channels'
require 'app'