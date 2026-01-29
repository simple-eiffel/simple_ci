<p align="center">
  <img src="docs/images/logo.svg" alt="simple_ library logo" width="400">
</p>

# Simple CI

A homebrew Continuous Integration tool for Eiffel projects. Built in-house for building, testing, and reporting on Eiffel project builds with zero external dependencies.

## Features

- Compiles and tests multiple Eiffel projects
- Automatic ec.exe detection via `ISE_EIFFEL` environment variable
- Per-project environment variable configuration
- GitHub status tracking per project
- JSON and text report generation (for Claude integration)
- Clean or incremental build modes
- Freeze or finalize compilation modes

## Installation

The compiled executable is located in `bin/simple_ci.exe`. Copy it to your PATH or run directly.

### Prerequisites

- EiffelStudio installed with `ISE_EIFFEL` environment variable set
- Or have `ec.exe` in your PATH

## Usage

```bash
# Run all projects
simple_ci.exe

# Run with verbose output
simple_ci.exe --verbose
simple_ci.exe -v

# Run specific project(s)
simple_ci.exe -p simple_sql
simple_ci.exe --project simple_web
simple_ci.exe -p simple_sql -p simple_web

# Fast incremental build (skip clean)
simple_ci.exe --no-clean

# Finalized build (optimized, slower)
simple_ci.exe --finalize

# Output JSON only (for parsing)
simple_ci.exe --json

# Show help
simple_ci.exe --help
simple_ci.exe -h
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--verbose` | `-v` | Show detailed build output |
| `--no-clean` | | Skip clean rebuild (faster, incremental) |
| `--finalize` | | Use finalize mode instead of freeze |
| `--json` | | Output JSON report only (for parsing) |
| `--project NAME` | `-p NAME` | Run specific project(s) - can repeat |
| `--help` | `-h` | Show usage help |

## Output Files

After running, Simple CI generates two report files:

- `ci_report.json` - Machine-readable JSON report (designed for Claude to parse)
- `ci_report.txt` - Human-readable text report

## Configured Projects

The following projects are configured for CI builds:

| Project | Dependencies | GitHub |
|---------|-------------|--------|
| simple_json | testing_ext | Yes |
| testing_ext | (none) | Yes |
| simple_process | testing_ext | Yes |
| simple_randomizer | testing_ext | Yes |
| simple_sql | simple_json, testing_ext | Yes |
| simple_web | simple_json, testing_ext, simple_sql, simple_process, simple_randomizer | Yes |
| simple_ai_client | simple_json, simple_process, simple_sql, testing_ext | Yes |
| simple_ec | testing_ext | No |

## Adding New Projects

Edit `src/ci_config.e` and add your project to the `standard_projects` feature:

```eiffel
-- project_name (dependencies) - GITHUB STATUS
create l_project.make ("project_name", "D:\prod\project_name\project_name.ecf")
l_project.add_target ("project_name_tests")
l_project.add_env_var ("DEPENDENCY", "D:\prod\dependency")
l_project.set_github ("D:\prod\project_name")  -- or set_not_on_github
Result.extend (l_project)
```

## Environment Variables

Simple CI automatically detects `ec.exe` via the `ISE_EIFFEL` environment variable. Each project can also specify its own environment variables for library dependencies:

- `TESTING_EXT` - testing_ext library location
- `SIMPLE_JSON` - simple_json library location
- `SIMPLE_PROCESS` - simple_process library location
- `SIMPLE_SQL` - simple_sql library location
- `SIMPLE_WEB` - simple_web library location
- `SIMPLE_RANDOMIZER` - simple_randomizer library location

## Exit Codes

- `0` - All builds passed
- `1` - One or more builds failed

## Claude Integration

The JSON report is specifically designed for Claude Code to parse and identify failures:

```json
{
  "timestamp": "2025-12-02T10:30:00",
  "summary": {
    "total": 8,
    "passed": 7,
    "failed": 1
  },
  "projects": [
    {
      "name": "simple_sql",
      "success": true,
      "duration_ms": 45000
    },
    {
      "name": "simple_web",
      "success": false,
      "error": "Compilation error in SIMPLE_WEB_SERVER line 42",
      "duration_ms": 30000
    }
  ]
}
```

Workflow with Claude:
1. Run `simple_ci.exe -p project_name`
2. If failures occur, share the `ci_report.json` with Claude
3. Claude analyzes the errors and suggests fixes
4. Apply fixes and re-run CI
5. Repeat until all tests pass

## Roadmap

### Completed
- [x] Core CI runner with ec.exe integration
- [x] Per-project environment variable configuration
- [x] JSON and text report generation
- [x] GitHub status tracking per project
- [x] Windows command handling with `cmd /c` wrapper
- [x] Working directory support (EIFGENs in correct location)
- [x] Clean/incremental build modes
- [x] Freeze/finalize compilation modes

### Planned
- [ ] Parallel builds (multiple projects simultaneously)
- [ ] Test execution after successful build
- [ ] Email/webhook notifications on failure
- [ ] Build history tracking (SQLite database)
- [ ] GitHub Actions integration
- [ ] Build artifact management

### Known Issues
- Large projects may timeout on first clean build
- Obsolete warnings counted but not detailed in report

## License

MIT License - Copyright (c) 2025, Larry Rix
