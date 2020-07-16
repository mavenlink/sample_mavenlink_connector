require_relative '../lib/connector_server'
require 'spec_helper'

describe ConnectorServer do
    describe '#actions' do
        it "returns an empty array" do 
            actions_request = Grpc::ActionsRequest.new()
            expect(described_class.new.actions(actions_request, {}).actions).to eq (
                    [Grpc::Action.new(display_name: "Close Project", description: "Close a project by archiving it", inputs: [
                            Grpc::Field.new(display_name: "Project ID", key: "project_id", type: "text", description: "The ID of the project to be closed.", required: true),
                            Grpc::Field.new(display_name: "App Account", key: "target", type: "app_account", description: "The Mavenlink app account for which to send the payload", required: true)],
                        outputs: [])]
            )
        end
    end

    describe '#triggers' do
        it 'returns an empty array' do
            triggers_req = Grpc::TriggersRequest.new()
            expect(described_class.new.triggers(triggers_req, {})).to eq Grpc::TriggersResponse.new(triggers: [])
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
        it 'exists' do 
            trigger_request = Grpc::TriggerRequest.new()
            described_class.new.perform_trigger(trigger_request)
        end
    end
end