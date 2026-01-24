# 7S-04: SIMPLE-STAR - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Ecosystem Integration

### Dependencies on Other simple_* Libraries
- **simple_json** - Config file parsing and report generation
- **simple_process** - Command execution for ec.exe
- **simple_date_time** - Timestamps for reports
- **simple_process_helper** - Process output capture

### Libraries That May Depend on simple_ci
- **simple_oracle** - CI status integration
- **simple_release** - Pre-release verification

### Integration Points

#### With simple_oracle
```eiffel
-- Oracle can query CI status
oracle.log_event ("CI", "All builds passed")
```

#### Workflow Integration
1. Claude runs `simple_ci.exe --verbose`
2. Reads `ci_report.json` for failures
3. Fixes issues in failing projects
4. Re-runs CI to verify
5. Commits changes if all pass

### Configuration Location
- `config.json` - Same directory as executable
- Contains project definitions

## Namespace Conventions
- Main classes: CI_* prefix
- Config: CI_CONFIG
- Runner: CI_RUNNER
- Results: CI_BUILD_RESULT
- Reports: CI_REPORT
