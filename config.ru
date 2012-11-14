# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run CiMonitor::Application

# require 'faye'
# Faye::WebSocket.load_adapter 'thin'
# faye = Faye::RackAdapter.new :mount      => '/faye',
                             # :timeout    => 25
# run faye
