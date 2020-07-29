require_relative "connector_service_definition/connector_services_pb"
require 'json'
require 'net/http'
require 'openssl'

class ConnectorServer < Grpc::Connector::Service
  def triggers(triggers_req, _unused_call)
    Grpc::TriggersResponse.new(triggers: [
      Grpc::Trigger.new(display_name: "Invoice Paid", type: "paid_invoice", app_key: "mavenlink", description: "Get paid invoices from Mavenlink", outputs: [
        Grpc::Field.new(display_name: "Project ID", key: "project_id", type: "text", description: "The ID of the project to be closed."),
        Grpc::Field.new(display_name: "Paid Invoice", key: "invoice", type: "text", description: "The paid invoice")
      ])
    ])
  end

  def actions(actions_request, _unused_call)
    actions = [
      Grpc::Action.new(display_name: "Close Project", description: "Close a project by archiving it", inputs: [
        Grpc::Field.new(display_name: "Project ID", key: "project_id", type: "text", description: "The ID of the project to be closed.", required: true),
        Grpc::Field.new(display_name: "App Account", key: "target", type: "app_account", app_key: "mavenlink", description: "The Mavenlink app account for which to send the payload", required: true)
      ], outputs: [])
    ]

    Grpc::ActionsResponse.new(actions: actions)
  end

  def perform_action(action_request, _unused_call=nil)
    app_account = JSON.parse(action_request.params["target"])
    project_id = action_request.params["project_id"]
    archive_project_from_id(app_account["token"], project_id)
  end

  def perform_trigger(trigger_request, _unused_call=nil)
    token = trigger_request.params["token"]
    last_polled_at = trigger_request.params["last_polled_at"]
    get_paid_invoices(token, last_polled_at)
  end

  private

  def get_paid_invoices(token, last_polled_at)
    url = URI("https://api.msync.mvn.link/api/v1/invoices?include=workspaces&order=updated_at:desc&updated_after=#{last_polled_at}&paid=true")
    https = Net::HTTP.new(url.host, url.port);
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bearer #{token}"

    response = https.request(request)
    invoices = JSON.parse(response.body)["invoices"]

    events = invoices.values.map { |invoice| Grpc::Event.new(payload: {"invoice" => invoice, "project_id" => invoice["workspace_ids"].first}.to_json, type: "paid_invoice")}
    Grpc::TriggerResponse.new(status: :SUCCESS, events: events)
  end

  def archive_project_from_id(token, project_id)
    begin
      authorization = "Bearer #{token}"
      url = URI("https://api.msync.mvn.link/api/v1/workspaces/#{project_id}")
      body = {"workspace": {"archived": true}}.to_json

      https = Net::HTTP.new(url.host, url.port);
      https.use_ssl = true
      request = Net::HTTP::Put.new(url)
      request["Authorization"] = authorization
      request["Content-Type"] = "application/json"
      request.body = body

      response = https.request(request)

      Grpc::ActionResponse.new(status: :SUCCESS, outputs: {})
    rescue => error
      Grpc::ActionResponse.new(status: :ERROR, outputs: {error: "Mavenlink API Error"})
    end
  end
end