#! /bin/ruby
require_relative "connector_server"

puts "Starting grpc server... welcome to awesome"
s = GRPC::RpcServer.new
s.add_http2_port("0.0.0.0:50055", :this_port_is_insecure)

s.handle(ConnectorServer)
s.run_till_terminated_or_interrupted([1, "int", "SIGQUIT"])