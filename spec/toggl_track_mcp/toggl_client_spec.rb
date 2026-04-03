# frozen_string_literal: true

RSpec.describe TogglTrackMcp::TogglClient do
  let(:api_token) { "test_token" }
  let(:client) { described_class.new(api_token) }
  let(:base_url) { "https://api.track.toggl.com/api/v9" }

  describe "#workspace_id" do
    it "fetches and caches the default workspace ID" do
      stub_request(:get, "#{base_url}/me")
        .with(basic_auth: [api_token, "api_token"])
        .to_return(body: '{"default_workspace_id": 12345}', headers: { "Content-Type" => "application/json" })

      expect(client.workspace_id).to eq(12345)
      expect(client.workspace_id).to eq(12345) # cached
      expect(a_request(:get, "#{base_url}/me")).to have_been_made.once
    end
  end

  describe "#current_entry" do
    it "returns the current time entry" do
      entry = { "id" => 1, "description" => "Working" }
      stub_request(:get, "#{base_url}/me/time_entries/current")
        .to_return(body: JSON.generate(entry), headers: { "Content-Type" => "application/json" })

      expect(client.current_entry).to eq(entry)
    end

    it "returns nil when no timer is running" do
      stub_request(:get, "#{base_url}/me/time_entries/current")
        .to_return(body: "", headers: { "Content-Type" => "application/json" })

      expect(client.current_entry).to be_nil
    end
  end

  describe "#create_entry" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
    end

    it "creates a new time entry" do
      response_body = { "id" => 99, "description" => "New task", "workspace_id" => 100 }
      stub_request(:post, "#{base_url}/workspaces/100/time_entries")
        .to_return(body: JSON.generate(response_body), headers: { "Content-Type" => "application/json" })

      result = client.create_entry(description: "New task")
      expect(result["id"]).to eq(99)
      expect(result["description"]).to eq("New task")
    end

    it "includes optional fields when provided" do
      stub_request(:post, "#{base_url}/workspaces/100/time_entries")
        .to_return(body: '{"id": 99}', headers: { "Content-Type" => "application/json" })

      client.create_entry(description: "Task", project_id: 5, tags: ["dev"])

      expect(a_request(:post, "#{base_url}/workspaces/100/time_entries")
        .with { |req|
          body = JSON.parse(req.body)
          body["project_id"] == 5 && body["tags"] == ["dev"]
        }).to have_been_made
    end
  end

  describe "#update_entry" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
    end

    it "updates a time entry" do
      stub_request(:put, "#{base_url}/workspaces/100/time_entries/42")
        .to_return(body: '{"id": 42, "description": "Updated"}', headers: { "Content-Type" => "application/json" })

      result = client.update_entry(time_entry_id: 42, description: "Updated")
      expect(result["description"]).to eq("Updated")
    end
  end

  describe "#delete_entry" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
    end

    it "deletes a time entry" do
      stub_request(:delete, "#{base_url}/workspaces/100/time_entries/42")
        .to_return(status: 200, body: "", headers: { "Content-Type" => "application/json" })

      expect(client.delete_entry(time_entry_id: 42)).to be_nil
    end
  end

  describe "#stop_entry" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
    end

    it "stops a running timer" do
      stub_request(:patch, "#{base_url}/workspaces/100/time_entries/42/stop")
        .to_return(body: '{"id": 42, "duration": 3600}', headers: { "Content-Type" => "application/json" })

      result = client.stop_entry(time_entry_id: 42)
      expect(result["id"]).to eq(42)
    end
  end

  describe "#projects" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
    end

    it "fetches workspace projects" do
      projects = [{ "id" => 1, "name" => "Project A" }]
      stub_request(:get, "#{base_url}/workspaces/100/projects")
        .to_return(body: JSON.generate(projects), headers: { "Content-Type" => "application/json" })

      expect(client.projects).to eq(projects)
    end
  end

  describe "#project_name" do
    before do
      stub_request(:get, "#{base_url}/me")
        .to_return(body: '{"default_workspace_id": 100}', headers: { "Content-Type" => "application/json" })
      stub_request(:get, "#{base_url}/workspaces/100/projects")
        .to_return(body: '[{"id": 1, "name": "Project A"}, {"id": 2, "name": "Project B"}]',
                   headers: { "Content-Type" => "application/json" })
    end

    it "returns the project name for a given ID" do
      expect(client.project_name(1)).to eq("Project A")
    end

    it "returns nil for nil project_id" do
      expect(client.project_name(nil)).to be_nil
    end

    it "returns nil for unknown project_id" do
      expect(client.project_name(999)).to be_nil
    end
  end

  describe "error handling" do
    it "raises on API error" do
      stub_request(:get, "#{base_url}/me/time_entries/current")
        .to_return(status: 403, body: "Forbidden")

      expect { client.current_entry }.to raise_error(RuntimeError, /Toggl API error: 403/)
    end
  end
end
