# S07: SPEC SUMMARY - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Executive Summary

simple_ci provides a complete Continuous Integration system for Eiffel projects, focused on the simple_* ecosystem. It automates builds, collects results, and generates reports optimized for both human and AI consumption.

## Key Design Decisions

### 1. JSON Configuration
Projects defined in JSON for easy editing and version control.

### 2. Structured Reports
JSON reports designed for Claude Code parsing with failure context.

### 3. Workflow Documentation
CI_WORKFLOW class captures complete fix-verify-commit cycle.

### 4. Environment Variable Support
Projects can specify env vars needed for compilation.

### 5. GitHub Integration
Projects track whether they're on GitHub for commit workflow.

## Class Summary

| Class | Purpose | Lines |
|-------|---------|-------|
| CI_CONFIG | Configuration loading | 214 |
| CI_PROJECT | Project data model | 209 |
| CI_RUNNER | Build orchestration | 415 |
| CI_BUILD_RESULT | Result tracking | 244 |
| CI_REPORT | Report generation | 321 |
| CI_WORKFLOW | Workflow docs | 115 |

## Feature Summary

- **Configuration:** JSON-based, supports env vars
- **Execution:** Sequential builds, verbose mode, clean/finalize options
- **Results:** Pass/fail, error/warning counts, duration
- **Reports:** JSON (machine) and text (human)
- **Workflow:** Documented fix-verify-commit cycle

## Contract Coverage

- All constructors have preconditions
- Project/target names validated as non-empty
- Runner tracks project/result consistency
- Results track timing and status
- Class invariants ensure object validity
