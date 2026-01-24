# S02: CLASS CATALOG - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Class Hierarchy

```
APPLICATION (entry point)
    |
    +-- uses --> CI_CONFIG (loads configuration)
    |                |
    |                +-- creates --> CI_PROJECT (project data)
    |
    +-- uses --> CI_RUNNER (build orchestration)
    |                |
    |                +-- creates --> CI_BUILD_RESULT (result tracking)
    |
    +-- uses --> CI_REPORT (report generation)

CI_WORKFLOW (documentation class)
```

## Class Descriptions

### CI_CONFIG
**Purpose:** Load project configurations from JSON
**Role:** Parse config.json, create CI_PROJECT instances
**Key Features:**
- `make` - Load configuration from file
- `projects` - List of configured projects
- `project_by_name` - Find project by name
- `available_project_names` - List all names
- `has_error`, `load_error` - Error tracking

### CI_PROJECT
**Purpose:** Represent a project to build
**Role:** Hold project metadata and configuration
**Key Features:**
- `name`, `ecf_path` - Identity
- `targets` - Build targets
- `environment_variables` - Env vars for build
- `is_enabled` - Enable/disable project
- `is_on_github`, `git_repo_path` - Git tracking
- `project_directory` - Extract directory from ECF path

### CI_RUNNER
**Purpose:** Orchestrate builds across projects
**Role:** Execute builds, collect results
**Key Features:**
- `add_project` - Add project to build list
- `run_all` - Build all enabled projects
- `run_project` - Build single project
- `run_target` - Build single target
- Statistics: `total_count`, `pass_count`, `fail_count`
- Settings: `is_verbose`, `is_clean_build`, `is_finalize`

### CI_BUILD_RESULT
**Purpose:** Track result of single build
**Role:** Capture success/failure, timing, output
**Key Features:**
- `project_name`, `target_name` - Identity
- `is_success` - Pass/fail status
- `output`, `error_message` - Build output
- `error_count`, `warning_count` - Counts
- `start_time`, `end_time` - Timing
- `duration_seconds`, `summary` - Derived values

### CI_REPORT
**Purpose:** Generate reports from build results
**Role:** Format results for consumption
**Key Features:**
- `to_json`, `to_json_pretty` - JSON output
- `to_text` - Human-readable output
- `save_json_report`, `save_text_report` - File output
- `failed_projects_array` - Quick failure list

### CI_WORKFLOW
**Purpose:** Document CI workflow for Claude
**Role:** Provide workflow steps and instructions
**Key Features:**
- `workflow_steps` - Ordered step list
- `claude_instructions` - Detailed instructions
- Command helpers
