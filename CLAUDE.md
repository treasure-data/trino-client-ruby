# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing
- `bundle exec rake spec` - Run all RSpec tests
- `bundle exec rspec spec/[filename]_spec.rb` - Run specific test file

### Building
- `bundle exec rake build` - Build the gem
- `bundle exec rake` - Default task (runs spec and build)

### Code Quality
- `bundle exec standardrb` - Run StandardRB linter (code style enforcement)
- `bundle exec standardrb --fix` - Auto-fix style issues

### Model Generation
- `bundle exec rake modelgen:latest` - Generate model files from latest Trino version
- `bundle exec rake modelgen:all` - Generate all model versions

## Architecture Overview

This is a Ruby client library for Trino (distributed SQL query engine). The architecture is layered:

### Core Components

1. **Client Layer** (`lib/trino/client/client.rb`):
   - `Trino::Client::Client` - Main API entry point
   - Provides `run()`, `run_with_names()`, `query()`, `kill()` methods
   - Handles synchronous and streaming query execution

2. **Query Layer** (`lib/trino/client/query.rb`):
   - `Query` class - Manages query execution lifecycle
   - Handles streaming results via `each_row`, `each_row_chunk`
   - Provides column metadata and result transformation

3. **Statement Client** (`lib/trino/client/statement_client.rb`):
   - `StatementClient` - Low-level HTTP communication with Trino
   - Manages query state machine (running, finished, failed, aborted)
   - Handles retries, timeouts, and error conditions
   - Supports both JSON and MessagePack response formats

4. **HTTP Layer** (`lib/trino/client/faraday_client.rb`):
   - Uses Faraday for HTTP requests with middleware for gzip and redirects
   - Handles authentication, SSL configuration, proxy settings

### Model System

- **Versioned Models** (`lib/trino/client/model_versions/`):
  - Generated from Trino source code for different Trino versions
  - Each version (351, 316, 303, etc.) has its own model definitions
  - Default is version 351

- **Model Generation** (`modelgen/`):
  - Automated model generation from Trino Java source
  - Downloads Trino source and extracts model definitions

### Key Features

- **Streaming Results**: Query results can be processed row-by-row without loading all data into memory
- **Timeout Control**: Supports both query-level and plan-level timeouts
- **Error Recovery**: Built-in retry logic for transient failures (502, 503, 504)
- **Multiple Result Formats**: Raw arrays, named hashes, or streaming iteration
- **ROW Type Support**: Can parse Trino ROW types into Ruby hashes via `transform_row`

### Testing

Tests are organized by component:
- `spec/client_spec.rb` - Client API tests
- `spec/statement_client_spec.rb` - Low-level protocol tests
- `spec/column_value_parser_spec.rb` - Data parsing tests
- `spec/tpch_query_spec.rb` - Integration tests with TPC-H queries
