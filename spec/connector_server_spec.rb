require_relative '../lib/connector_server'

describe ConnectorServer do
    describe '#actions' do
        it "returns an empty array" do 
            actions_request = Grpc::ActionsRequest.new()
            expect(described_class.new.actions(actions_request, {})).to eq Grpc::ActionsResponse.new(actions: [])
        end
    end

    describe '#triggers' do
        it 'returns an empty array' do
            triggers_req = Grpc::TriggersRequest.new()
            expect(described_class.new.triggers(triggers_req, {})).to eq Grpc::TriggersResponse.new(triggers: [])
        end
    end

    describe '#perform_action' do
        it 'exists' do
            action_request = Grpc::ActionRequest.new()
            described_class.new.perform_action(action_request)
        end
    end

    describe '#perform_trigger' do
        it 'exists' do 
            trigger_request = Grpc::TriggerRequest.new()
            described_class.new.perform_trigger(trigger_request)
        end
    end
end