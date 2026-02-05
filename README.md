# claude-code-el-http-poll

A community event source for [claude-code-event-listeners](https://github.com/mividtim/claude-code-event-listeners). Polls a URL until the response matches a condition.

## Install

```bash
# One command — requires the el plugin
/el:register https://raw.githubusercontent.com/mividtim/claude-code-el-http-poll/main/http-poll.sh

# Or clone and register locally
git clone https://github.com/mividtim/claude-code-el-http-poll.git
/el:register ./claude-code-el-http-poll/http-poll.sh
```

After registering, verify with `/el:list` — you should see `http-poll (user)`.

## Usage

```
event-listen.sh http-poll <url> [expected_status=200] [body_contains=] [interval=2] [timeout=300]
```

Or just tell Claude what you want:

```
You: "wait for the staging deploy to finish"
Claude: starts background task → event-listen.sh http-poll https://staging.example.com/health 200 "" 5 600
... polls every 5s for up to 10 minutes ...
<task-notification> → Service is healthy! Claude continues with next steps.
```

## Examples

**Wait for a service to come up:**
```bash
event-listen.sh http-poll http://localhost:3000/health
```

**Wait for a deploy to finish (check status field):**
```bash
event-listen.sh http-poll https://api.example.com/deploy/status 200 '"status":"complete"' 10 600
```

**Wait for a 404 to become a 200 (resource created):**
```bash
event-listen.sh http-poll https://api.example.com/users/42 200 "" 5 120
```

**Wait for a specific response body:**
```bash
event-listen.sh http-poll https://api.example.com/queue/jobs 200 '"pending":0' 30 1800
```

## Event Source Protocol

This script follows the [Event Source Protocol](https://github.com/mividtim/claude-code-event-listeners#the-event-source-protocol):

1. Receives args as `$@`
2. Blocks until the URL responds with the expected status (and optional body match)
3. Outputs the matching response body to stdout
4. Exits with code 0 (matched) or 1 (timed out)

## Requirements

- `curl`
- [claude-code-event-listeners](https://github.com/mividtim/claude-code-event-listeners) plugin

## License

MIT
