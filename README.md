# GovWifi NotifyPit

**NotifyPit** is a lightweight, containerized mock of the GOV.UK Notify API. It serves as a drop-in replacement for development and smoke testing, allowing the GovWifi team to simulate SMS/Email flows without hitting real API limits or incurring costs.



## Features
- **Stateless API Mock**: Implements the endpoints expected by the `notifications-ruby-client`.
- **Credential Generation**: Automatically generates GovWifi-formatted usernames (6 lowercase chars) and passwords (3 capitalized words) in the notification body.
- **Inbound Simulation**: Trigger application logic by injecting inbound SMS via the management API.
- **CI/CD Ready**: Docker-based workflow with parallel linting (RuboCop) and testing (RSpec).

---

## Quick Start

### 1. Run with Docker
The most reliable way to start NotifyPit is via the provided Makefile:
```bash
make serve
```
The service will be available at `http://localhost:4567`.

### 2. Run Locally (Ruby 4.0.0+)
If you have Ruby installed locally:
```bash
make local-build
make local-serve
```

---

## Integration with Smoke Tests

NotifyPit is swapped with the real Notify API using environment variables. No code changes are required in the GovWifi application logic.

### Step A: Configure GovWifi App
Set these variables in your environment to point the Notify client to the mock:

```bash
# Point the Notify Client to the mock container
NOTIFY_BASE_URL=http://notifypit:4567

# A dummy key is required by the client (format: name-uuid-uuid)
NOTIFY_API_KEY=mock_key-g69-0000-0000-0000-0000
```

### Step B: The Smoke Test Flow
Follow this pattern to verify your signup logic:

1. **Trigger Inbound SMS**:
   Simulate a user texting 'WiFi' to the service:
   ```bash
   curl -X POST http://localhost:4567/mocker/inbound-sms \
     -d '{"phone_number": "07700900000", "content": "WiFi"}'
   ```

2. **Retrieve Sent Credentials**:
   Query the mock store to extract the generated username and password:
   ```bash
   curl -X GET http://localhost:4567/mocker/messages
   ```
   Filter the response for the message sent to `07700900000`. Use the `personalisation` or `body` fields to proceed with your RADIUS test.

3. **Reset State**:
   Clear the in-memory store between test runs:
   ```bash
   curl -X DELETE http://localhost:4567/mocker/reset
   ```

---

## Development & CI

This project enforces high code quality via the following Docker-based commands:

| Command | Action |
| :--- | :--- |
| `make lint` | Runs RuboCop to ensure style compliance. |
| `make test` | Runs RSpec and generates a coverage report (>85% required). |
| `make clean` | Stops and removes all containers and networks. |



### Project Structure
- `lib/notify_pit.rb`: Main Sinatra controller and routing.
- `lib/notify_pit/store.rb`: Handles in-memory persistence of messages.
- `lib/notify_pit/generator.rb`: Logic for GovWifi credential and body generation.
- `spec/`: RSpec tests and SimpleCov configuration.