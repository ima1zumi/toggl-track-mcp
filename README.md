# toggl-track-mcp-server

An MCP server for Toggl Track.

## Setup

```
bundle install
cp .env.example .env
```

Set your Toggl Track API token in `.env`. You can find it at [Toggl Track Profile](https://track.toggl.com/profile).

`TOGGL_TZ` is the timezone offset (default: `+09:00`).

## Usage

Example configuration for Claude Desktop:

```json
{
  "mcpServers": {
    "toggl-track": {
      "command": "ruby",
      "args": ["server.rb"],
      "cwd": "/path/to/toggl-track-mcp-server",
      "env": {
        "TOGGL_API_TOKEN": "your_api_token_here"
      }
    }
  }
}
```

## Tools

| Tool | Description |
|---|---|
| get_current_entry | Get the currently running time entry |
| get_today_entries | List today's time entries |
| get_entries_by_date | Get time entries for a specific date |
| get_daily_summary | Get a daily summary |
| get_projects | List projects |
| create_entry | Create a time entry |
| update_entry | Update a time entry |
| stop_entry | Stop the running time entry |
| delete_entry | Delete a time entry |

## License

MIT
