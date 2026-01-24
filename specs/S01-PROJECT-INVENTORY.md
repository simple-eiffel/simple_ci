# S01: PROJECT INVENTORY - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Project Structure

```
simple_ci/
    src/
        application.e           -- CLI entry point
        ci_config.e             -- Configuration loader
        ci_project.e            -- Project entity
        ci_runner.e             -- Build orchestrator
        ci_build_result.e       -- Build result tracking
        ci_report.e             -- Report generator
        ci_workflow.e           -- Workflow documentation
    testing/
        test_app.e              -- Test application
        lib_tests.e             -- Test suite
    research/
        7S-01-SCOPE.md
        7S-02-STANDARDS.md
        7S-03-SOLUTIONS.md
        7S-04-SIMPLE-STAR.md
        7S-05-SECURITY.md
        7S-06-SIZING.md
        7S-07-RECOMMENDATION.md
    specs/
        S01-PROJECT-INVENTORY.md
        S02-CLASS-CATALOG.md
        S03-CONTRACTS.md
        S04-FEATURE-SPECS.md
        S05-CONSTRAINTS.md
        S06-BOUNDARIES.md
        S07-SPEC-SUMMARY.md
        S08-VALIDATION-REPORT.md
    simple_ci.ecf               -- Project configuration
    config.json                 -- Project definitions
```

## File Inventory

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| application.e | Source | ~100 | CLI interface |
| ci_config.e | Source | 214 | JSON config loading |
| ci_project.e | Source | 209 | Project data model |
| ci_runner.e | Source | 415 | Build orchestration |
| ci_build_result.e | Source | 244 | Result tracking |
| ci_report.e | Source | 321 | Report generation |
| ci_workflow.e | Source | 115 | Workflow docs |

## External Dependencies

| Dependency | Type | Location |
|------------|------|----------|
| simple_json | Library | /d/prod/simple_json |
| simple_process | Library | /d/prod/simple_process |
| simple_date_time | Library | /d/prod/simple_date_time |
| EiffelStudio ec.exe | Runtime | ISE_EIFFEL |
