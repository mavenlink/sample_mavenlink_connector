#! /bin/bash

bundle exec grpc_tools_ruby_protoc --ruby_out=lib --grpc_out=lib connector_service_definition/connector.proto
