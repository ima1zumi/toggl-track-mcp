# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::StopEntry do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    context "when no timer is running" do
      before { allow(client).to receive(:current_entry).and_return(nil) }

      it "returns a message saying no timer is running" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to eq("No timer is currently running.")
      end
    end

    context "when a timer is running" do
      let(:current) { { "id" => 42 } }
      let(:stopped_entry) do
        {
          "id" => 42,
          "description" => "Working",
          "start" => "2026-04-01T01:00:00Z",
          "stop" => "2026-04-01T02:00:00Z",
          "project_id" => 10,
          "tags" => [],
        }
      end

      before do
        allow(client).to receive(:current_entry).and_return(current)
        allow(client).to receive(:stop_entry).with(time_entry_id: 42).and_return(stopped_entry)
        allow(client).to receive(:project_name).with(10).and_return("Dev")
      end

      it "stops the timer and shows details" do
        response = described_class.call(server_context: server_context)
        text = response_text(response)
        expect(text).to include("Timer stopped")
        expect(text).to include("Description: Working")
        expect(text).to include("Project: Dev")
        expect(text).to include("Entry ID: 42")
      end
    end
  end
end
