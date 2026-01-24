# 7S-01: SCOPE - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Problem Domain

Continuous Integration (CI) for Eiffel projects. Automates the build-test-report cycle for multiple simple_* ecosystem libraries, detecting compilation failures and providing structured reports.

## Target Users

- Developers maintaining the simple_* ecosystem
- Automated build systems
- Claude Code sessions needing to verify ecosystem health
- Release engineers preparing production builds

## Boundaries

### In Scope
- Loading project configurations from JSON
- Executing EiffelStudio compiler (ec.exe)
- Running test targets
- Collecting build results (pass/fail, warnings, errors)
- Generating JSON and text reports
- Tracking build duration
- Environment variable management for builds
- GitHub repository tracking for projects

### Out of Scope
- Git operations (handled separately)
- Deployment/release
- Code coverage analysis
- Static analysis
- Performance testing
- Remote CI servers (GitHub Actions, etc.)
- Parallel builds

## Dependencies

- EiffelStudio 25.02+ (ec.exe compiler)
- simple_json (for config parsing)
- simple_process (for command execution)
- simple_date_time (for timestamps)
