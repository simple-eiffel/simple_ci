# 7S-03: SOLUTIONS - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Existing Solutions Comparison

### 1. Manual Build Scripts (bash/batch)
- **Pros:** Simple, flexible
- **Cons:** No structured reporting, error-prone

### 2. GitHub Actions
- **Pros:** Cloud-based, integrated with repo
- **Cons:** Requires internet, EiffelStudio setup complex

### 3. Jenkins
- **Pros:** Full-featured, plugins
- **Cons:** Heavy infrastructure, overkill for local dev

### 4. simple_ci (chosen solution)
- **Pros:** Eiffel-native, ecosystem-aware, Claude-friendly reports
- **Cons:** Local only, no distribution

### 5. Custom Makefiles
- **Pros:** Standard tool
- **Cons:** Not Eiffel-aware, poor error parsing

## Why simple_ci?

1. **Eiffel-native** - Written in Eiffel, understands Eiffel projects
2. **Ecosystem-aware** - Knows about simple_* dependencies
3. **Claude-optimized** - JSON reports designed for AI parsing
4. **Lightweight** - No infrastructure required
5. **Integrated workflow** - Works with oracle, handoff system
6. **Error parsing** - Extracts meaningful error context from compiler output
