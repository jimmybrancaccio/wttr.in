# Copilot Instructions for wttr.in

Short, action-oriented notes to help AI coding agents be productive in this repository.

1) Project overview
- Purpose: a Go HTTP server (`srv.go`) that dispatches weather queries to a request processor and renders responses in multiple formats. Python code in `lib/` provides legacy/formatting helpers (PNG, HTML, various views).
- High-level flow: HTTP request -> `internal/processor` (RequestProcessor) -> geo lookup (`internal/geo/*`) -> pick view/renderer (`internal/view` or `lib/view`) -> return body.

2) Key entry points & directories (start here)
- `srv.go` — main HTTP server and CLI flags: [srv.go](../srv.go#L1)
- `internal/processor` — core request processing and pipeline (see `processor.go`): [internal/processor/processor.go](../internal/processor/processor.go#L1)
- `internal/geo` — geo IP and location searchers
- `internal/config` — config loading and `Default()` values
- `lib/` — Python view/rendering helpers; see `lib/view` for v1/v2 renderers
- `share/` and `templates/` — static assets and HTML templates
- `Makefile` and `Dockerfile` — common build/run flows: [Makefile](../Makefile#L1), [Dockerfile](../Dockerfile#L1)

3) Build / run / debug (concrete commands)
- Build Go server: `make srv` (or `go build -o srv .`). See `Makefile` target `srv`.
- Run locally: `./srv --config-file config/services/services.yaml` (or `./srv` to use defaults).
- Useful CLI flags (defined in `srv.go`): `--config-check`, `--config-dump`, `--log-level` (short `-l`), `--convert-geo-ip-cache`, `--geo-resolve`.
- Tests / lint: `go test ./...` and `golangci-lint run ./...` (targets in `Makefile`).
- Docker: image build follows `Dockerfile` (multi-stage: Go builder + Python runtime); container exposes port `8002` by default and uses `supervisord`.

4) Project-specific conventions & patterns
- Mixed-language runtime: Go implements the HTTP server and core pipeline; Python `lib/` contains many rendering/formatting utilities — modifications to output formats often require editing `lib/view/*`.
- Configuration: YAML under `config/` and `spec/options/options.yaml`. The server reads a config file via `--config-file` or `config.Default()`.
- Logging: request logging uses `internal/logging` (RequestLogger). Use `--log-level` to increase verbosity when debugging.
- Geo data: the app expects a GeoLite DB (env `WTTR_GEOLITE`). See `Dockerfile` for env names used in production.
- Scripts and helpers: `share/scripts` contains helper build scripts (e.g., `build-welang.sh` used in Dockerfile to build `wego`).

5) Integration points & external dependencies
- `wego` binary (built by `share/scripts/build-welang.sh`) is bundled for some datasource tasks — `go` build stage creates `/app/go/bin/wego`.
- Python dependencies are declared in `requirements.txt`; Dockerfile installs them into a venv used by runtime.
- External DB: GeoLite2 MMDB file used for geolocation lookups.

6) Quick editing pointers (examples)
- To change HTTP behavior or middleware: edit `srv.go` and `internal/processor`.
- To change how a view is rendered (text/PNG/HTML): edit `lib/view/*` (Python) or `internal/view/*` (Go v1 views).
- To tweak templates: edit `templates/index.html` and `share/` assets.

7) What an AI should not assume
- Do not assume the repository is single-language: changes to output often need touching both Go and Python code.
- Do not assume tests exist for the feature; prefer small manual runs and `--log-level=debug` for verification.

If any of these sections should be expanded (specific files, example diffs, or more run/debug recipes), tell me which area to elaborate.
