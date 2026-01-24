# 7S-02: STANDARDS - simple_ci


**Date**: 2026-01-23

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Applicable Standards

### CI/CD Principles
- **Continuous Integration:** Frequent builds, immediate feedback
- **Build Once:** Same code, same binary
- **Fail Fast:** Quick detection of problems

### EiffelStudio Compiler
- Batch mode: `-batch` flag for non-interactive builds
- Target specification: `-target <name>`
- Compilation modes: `-freeze`, `-finalize`, `-c_compile`
- Clean builds: `-clean` flag

### JSON Configuration
```json
{
    "projects": [
        {
            "name": "library_name",
            "ecf": "path/to/library.ecf",
            "test_target": "library_tests",
            "github": "path/to/repo",
            "env_vars": {"VAR": "value"}
        }
    ]
}
```

### Report Formats

#### JSON Report
- Machine-readable for automation
- Includes summary, results array, failed projects
- Failure context for debugging

#### Text Report
- Human-readable console output
- Pass/fail counts
- Duration information

### Exit Codes
- 0: All builds passed
- Non-zero: Build or compilation failure
