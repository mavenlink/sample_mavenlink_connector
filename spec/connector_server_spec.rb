require_relative '../lib/connector_server'
require 'spec_helper'

describe ConnectorServer do
    describe '#actions' do
        it "returns a list of actions" do 
            actions_request = Grpc::ActionsRequest.new()
            expect(described_class.new.actions(actions_request, {}).actions).to eq (
                    [Grpc::Action.new(display_name: "Close Project", description: "Close a project by archiving it", inputs: [
                      Grpc::Field.new(display_name: "Project ID", key: "project_id", type: "text", description: "The ID of the project to be closed.", required: true),
                      Grpc::Field.new(display_name: "App Account", key: "target", type: "app_account",app_key: "mavenlink", description: "The Mavenlink app account for which to send the payload", required: true)
                      ], outputs: [])]
            )
        end
    end

    describe '#triggers' do
        it 'returns a list of triggers' do
            triggers_req = Grpc::TriggersRequest.new()

            expect(described_class.new.triggers(triggers_req, {}).triggers).to eq(
                [Grpc::Trigger.new(display_name: "Invoice Paid", type: "paid_invoice", app_key: "mavenlink", description: "Get paid invoices from Mavenlink", outputs: [
                  Grpc::Field.new(display_name: "Project ID", key: "project_id", type: "text", description: "The ID of the project to be closed."),
                  Grpc::Field.new(display_name: "Paid Invoice", key: "invoice", type: "text", description: "The paid invoice")
                ])
              ])
        end
    end

    describe '#perform_action' do
        it 'it can close a project' do
          stub_request(:put, "https://api.msync.mvn.link/api/v1/workspaces/123").
          with(
            body: "{\"workspace\":{\"archived\":true}}",
            headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer whatever',
              'Content-Type'=>'application/json',
              'Host'=>'api.msync.mvn.link',
              'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: "", headers: {})

          action_request = Grpc::ActionRequest.new(action:
              Grpc::Action.new(display_name: "Close Project"), params:
                {
                  "target" => {token: "whatever"}.to_json,
                  "project_id" => "123"
                }
            )
          response = described_class.new.perform_action(action_request)
          expect(response.status).to eq :SUCCESS
          expect(response.outputs).to eq({})
        end
    end

    describe '#perform_trigger' do
        it 'will pull the work id for the most recently paid invoice' do
          file = File.read('./spec/fixtures/invoice_paid_fixture.json')
          body = file
          last_polled_at = "2020-07-29T17:37:25"

          stub_request(:get, "https://api.msync.mvn.link/api/v1/invoices?include=workspaces&order=updated_at:desc&updated_after=#{last_polled_at}&paid=true").
        with(
          headers: {
       	    'Accept'=>'*/*',
       	    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	    'Authorization'=>'Bearer whatever',
       	    'Host'=>'api.msync.mvn.link',
       	    'User-Agent'=>'Ruby'
          }).
            to_return(status: 200, body: body, headers: {})

          trigger_request = Grpc::TriggerRequest.new(trigger: 
            Grpc::Trigger.new(display_name: "Invoice Paid", type: "invoice_paid", app_key: "mavenlink"), params: {"token" => "whatever", "last_polled_at" => "2020-07-29T17:37:25"}
          )
          invoices = JSON.parse(body)["invoices"]

          events = invoices.values.map { |invoice| Grpc::Event.new(payload: {"invoice" => invoice, "project_id" => invoice["workspace_ids"].first}.to_json, type: "paid_invoice")}
          
          response = described_class.new.perform_trigger(trigger_request)
          expect(response.status).to eq :SUCCESS
          expect(response).to eq(Grpc::TriggerResponse.new(status: :SUCCESS, events: events ))
        end
    end
end