# frozen_string_literal: true

RSpec.describe TogglTrackMcp::Tools::DeleteEntry do
  let(:client) { build_client_double }
  let(:server_context) { { client: client } }

  describe ".call" do
    before do
      allow(client).to receive(:delete_entry).with(time_entry_id: 42).and_return(nil)
    end

    it "deletes the entry and returns confirmation" do
      response = described_class.call(time_entry_id: 42, server_context: server_context)
      expect(response_text(response)).to eq("Time entry 42 deleted.")
    end

    it "calls delete_entry on the client" do
      described_class.call(time_entry_id: 42, server_context: server_context)
      expect(client).to have_received(:delete_entry).with(time_entry_id: 42)
    end
  end
end
