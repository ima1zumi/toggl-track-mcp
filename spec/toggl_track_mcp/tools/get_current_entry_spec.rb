# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::GetCurrentEntry do
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
      let(:entry) do
        {
          "id" => 123,
          "description" => "Writing tests",
          "start" => "2026-04-01T01:00:00Z",
          "project_id" => 5,
          "tags" => ["dev", "ruby"],
          "duration" => -1,
        }
      end

      before do
        allow(client).to receive(:current_entry).and_return(entry)
        allow(client).to receive(:project_name).with(5).and_return("MCP Server")
      end

      it "includes the description" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Description: Writing tests")
      end

      it "includes the project name" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Project: MCP Server")
      end

      it "includes tags" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Tags: dev, ruby")
      end

      it "includes the entry ID" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("Entry ID: 123")
      end
    end

    context "when entry has no project or tags" do
      let(:entry) do
        {
          "id" => 456,
          "description" => nil,
          "start" => "2026-04-01T01:00:00Z",
          "project_id" => nil,
          "tags" => [],
          "duration" => -1,
        }
      end

      before do
        allow(client).to receive(:current_entry).and_return(entry)
      end

      it "shows (no description) for nil description" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).to include("(no description)")
      end

      it "does not include Project line" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).not_to include("Project:")
      end

      it "does not include Tags line" do
        response = described_class.call(server_context: server_context)
        expect(response_text(response)).not_to include("Tags:")
      end
    end
  end
end
