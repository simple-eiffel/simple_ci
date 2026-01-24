# S05: CONSTRAINTS - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Technical Constraints

### 1. EiffelStudio Dependency
- **Constraint:** Requires ec.exe from EiffelStudio
- **Impact:** Must have EiffelStudio installed
- **Mitigation:** Auto-detect from ISE_EIFFEL env var

### 2. Sequential Builds
- **Constraint:** Builds run sequentially, not parallel
- **Impact:** Slower for many projects
- **Mitigation:** Future parallel build support

### 3. Windows Platform
- **Constraint:** Uses Windows cmd.exe for env vars
- **Impact:** Windows-only
- **Mitigation:** Could add Unix support

### 4. Config File Location
- **Constraint:** config.json must be next to executable
- **Impact:** Fixed location
- **Mitigation:** Command-line override (future)

### 5. Compiler Output Parsing
- **Constraint:** Parses text output from ec.exe
- **Impact:** May break with compiler changes
- **Mitigation:** Flexible pattern matching

## Resource Limits

| Resource | Limit | Notes |
|----------|-------|-------|
| Projects | No limit | Memory bound |
| Targets per project | No limit | Array list |
| Build duration | No timeout | Compiler may hang |

## Performance Constraints

| Operation | Constraint |
|-----------|------------|
| Config loading | < 100ms |
| Build time | Depends on project |
| Report generation | < 1s |
