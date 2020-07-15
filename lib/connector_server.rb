require_relative "connector_service_definition/connector_services_pb"

class ConnectorServer < Grpc::Connector::Service
  def triggers(triggers_req, _unused_call)
    Grpc::TriggersResponse.new(triggers: [])
  end

  def actions(actions_req, _unused_call)
    Grpc::ActionsResponse.new(actions: [])
  end

  def perform_action(action_request, _unused_call=nil)
  end

  def perform_trigger(trigger_request, _unused_call=nil)
  end
end