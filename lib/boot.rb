require 'rubygems'
require 'bundler'

Bundler.require

$:.unshift File.expand_path(File.dirname(__FILE__))
require 'language_detector'
require 'twitter_feed'
