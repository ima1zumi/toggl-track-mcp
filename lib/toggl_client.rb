# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "time"

class TogglClient
  BASE_URL = "https://api.track.toggl.com/api/v9"
  CREATED_WITH = "toggl-track-mcp"

  attr_reader :tz

  def initialize(api_token = ENV.fetch("TOGGL_API_TOKEN"), tz: ENV.fetch("TOGGL_TZ", "+09:00"))
    @api_token = api_token
    @tz = tz
    @workspace_id = nil
    @project_map = nil
  end

  def workspace_id
    @workspace_id ||= get("/me").fetch("default_workspace_id")
  end

  def current_entry
    get("/me/time_entries/current")
  end

  def project_map
    @project_map ||= projects.each_with_object({}) { |p, h| h[p["id"]] = p["name"] }
  end

  def project_name(project_id)
    return nil unless project_id

    project_map[project_id]
  end

  def today_entries
    today = Time.now.getlocal(@tz)
    start_of_day = Time.new(today.year, today.month, today.day, 0, 0, 0, @tz)
    end_of_day = start_of_day + 86400
    get("/me/time_entries", start_date: start_of_day.iso8601, end_date: end_of_day.iso8601)
  end

  def entries_by_date(start_date:, end_date:)
    get("/me/time_entries", start_date: start_date, end_date: end_date)
  end

  def create_entry(description:, project_id: nil, tags: nil, start: nil, duration: -1)
    body = {
      description: description,
      workspace_id: workspace_id,
      start: start || Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
      duration: duration,
      created_with: CREATED_WITH,
    }
    body[:project_id] = project_id if project_id
    body[:tags] = tags if tags

    post("/workspaces/#{workspace_id}/time_entries", body)
  end

  def update_entry(time_entry_id:, **params)
    body = {}
    body[:description] = params[:description] if params.key?(:description)
    body[:project_id] = params[:project_id] if params.key?(:project_id)
    body[:tags] = params[:tags] if params.key?(:tags)
    body[:start] = params[:start] if params.key?(:start)
    body[:stop] = params[:stop] if params.key?(:stop)

    put("/workspaces/#{workspace_id}/time_entries/#{time_entry_id}", body)
  end

  def delete_entry(time_entry_id:)
    delete("/workspaces/#{workspace_id}/time_entries/#{time_entry_id}")
  end

  def stop_entry(time_entry_id:)
    patch("/workspaces/#{workspace_id}/time_entries/#{time_entry_id}/stop")
  end

  def projects
    get("/workspaces/#{workspace_id}/projects")
  end

  private

  def get(path, params = {})
    uri = build_uri(path, params)
    request = Net::HTTP::Get.new(uri)
    execute(uri, request)
  end

  def post(path, body)
    uri = build_uri(path)
    request = Net::HTTP::Post.new(uri)
    request.body = JSON.generate(body)
    request["Content-Type"] = "application/json"
    execute(uri, request)
  end

  def put(path, body)
    uri = build_uri(path)
    request = Net::HTTP::Put.new(uri)
    request.body = JSON.generate(body)
    request["Content-Type"] = "application/json"
    execute(uri, request)
  end

  def patch(path, body = nil)
    uri = build_uri(path)
    request = Net::HTTP::Patch.new(uri)
    if body
      request.body = JSON.generate(body)
      request["Content-Type"] = "application/json"
    end
    execute(uri, request)
  end

  def delete(path)
    uri = build_uri(path)
    request = Net::HTTP::Delete.new(uri)
    execute(uri, request)
  end

  def build_uri(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params) unless params.empty?
    uri
  end

  def execute(uri, request)
    request.basic_auth(@api_token, "api_token")

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    case response
    when Net::HTTPSuccess
      return nil if response.body.nil? || response.body.empty?
      JSON.parse(response.body)
    else
      raise "Toggl API error: #{response.code} #{response.body}"
    end
  end
end
