$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'app'
run HttpService

