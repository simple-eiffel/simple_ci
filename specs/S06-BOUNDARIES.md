# S06: BOUNDARIES - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## API Boundaries

### Public Interface

#### CI_CONFIG
- `make` - Constructor (loads config)
- `projects` - Project list
- `project_by_name` - Find by name
- `available_project_names` - Name list
- `has_error`, `load_error` - Error access

#### CI_PROJECT
- All creation and access features
- Modification features (add_target, etc.)
- Query features (project_directory, etc.)

#### CI_RUNNER
- `make` - Constructor
- `add_project` - Add project
- `run_*` - Execution features
- Statistics features
- Configuration features

#### CI_BUILD_RESULT
- `make`, `make_failed` - Constructors
- All access features
- Status modification features

#### CI_REPORT
- `make` - Constructor
- Report generation features
- File output features

### Internal Interface (NONE)

- Config parsing helpers
- Command building
- Output parsing
- Timestamp formatting

## Integration Points

| Component | Interface | Direction |
|-----------|-----------|-----------|
| config.json | File read | Inbound |
| ec.exe | Process exec | Outbound |
| ci_report.json | File write | Outbound |
| ci_report.txt | File write | Outbound |
| Console | Print | Outbound |
