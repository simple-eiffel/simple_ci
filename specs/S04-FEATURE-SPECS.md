# S04: FEATURE SPECS - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Feature Specifications

### CI_CONFIG Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | | Load config from file |
| projects | : ARRAYED_LIST [CI_PROJECT] | All configured projects |
| project_by_name | (name: STRING_32): detachable CI_PROJECT | Find by name |
| available_project_names | : ARRAYED_LIST [STRING_32] | List all names |
| has_error | : BOOLEAN | Loading failed? |
| load_error | : STRING_32 | Error message |

### CI_PROJECT Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (name, ecf_path: STRING_32) | Create project |
| name | : STRING_32 | Project name |
| ecf_path | : STRING_32 | Path to ECF |
| targets | : ARRAYED_LIST [STRING_32] | Build targets |
| add_target | (target: STRING_32) | Add target |
| environment_variables | : HASH_TABLE | Env vars |
| add_env_var | (name, value: STRING_32) | Add env var |
| is_enabled | : BOOLEAN | Is enabled? |
| enable / disable | | Toggle enabled |
| is_on_github | : BOOLEAN | Has git repo? |
| set_github | (repo_path: STRING_32) | Set repo |
| project_directory | : STRING_32 | Extract directory |

### CI_RUNNER Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | | Initialize runner |
| projects | : ARRAYED_LIST [CI_PROJECT] | Project list |
| results | : ARRAYED_LIST [CI_BUILD_RESULT] | Build results |
| add_project | (project: CI_PROJECT) | Add project |
| run_all | | Build all enabled |
| run_project | (project: CI_PROJECT) | Build project |
| run_target | (project: CI_PROJECT; target: STRING_32) | Build target |
| total_count | : INTEGER | Total builds |
| pass_count | : INTEGER | Successful builds |
| fail_count | : INTEGER | Failed builds |
| all_passed | : BOOLEAN | All successful? |
| set_verbose | (v: BOOLEAN) | Toggle verbose |
| set_clean_build | (c: BOOLEAN) | Toggle clean |
| set_finalize | (f: BOOLEAN) | Toggle finalize |
| print_summary | | Print to console |

### CI_BUILD_RESULT Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (project, target: STRING_32) | Create result |
| project_name | : STRING_32 | Project name |
| target_name | : STRING_32 | Target name |
| is_success | : BOOLEAN | Pass/fail |
| output | : STRING_32 | Full output |
| error_message | : STRING_32 | Error if failed |
| error_count | : INTEGER | Error count |
| warning_count | : INTEGER | Warning count |
| start_time / end_time | : SIMPLE_DATE_TIME | Timing |
| duration_seconds | : INTEGER_64 | Duration |
| summary | : STRING_32 | One-line summary |
| set_success / set_failed | | Set status |
| mark_start / mark_end | | Record time |

### CI_REPORT Features

| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (runner: CI_RUNNER) | Create from runner |
| to_json | : STRING_32 | JSON report |
| to_json_pretty | : STRING_32 | Formatted JSON |
| to_text | : STRING_32 | Text report |
| save_json_report | (path: STRING) | Save JSON |
| save_text_report | (path: STRING) | Save text |
