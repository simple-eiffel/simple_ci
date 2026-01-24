# S03: CONTRACTS - simple_ci

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library:** simple_ci

## Design by Contract Summary

### CI_PROJECT Contracts

#### make
```eiffel
require
    name_not_empty: not a_name.is_empty
    ecf_path_not_empty: not a_ecf_path.is_empty
ensure
    name_set: name = a_name
    ecf_path_set: ecf_path = a_ecf_path
    enabled_by_default: is_enabled
    not_on_github_by_default: not is_on_github
```

#### add_target
```eiffel
require
    target_not_empty: not a_target.is_empty
ensure
    target_added: targets.has (a_target)
```

#### set_github
```eiffel
require
    path_not_empty: not a_repo_path.is_empty
ensure
    on_github: is_on_github
    path_set: git_repo_path = a_repo_path
```

### CI_RUNNER Contracts

#### add_project
```eiffel
require
    project_attached: a_project /= Void
ensure
    project_added: projects.has (a_project)
```

#### set_ec_path
```eiffel
require
    path_not_empty: not a_path.is_empty
ensure
    path_set: ec_path = a_path
```

#### run_target
```eiffel
require
    project_attached: a_project /= Void
    target_not_empty: not a_target.is_empty
```

### CI_BUILD_RESULT Contracts

#### make
```eiffel
require
    project_not_empty: not a_project.is_empty
    target_not_empty: not a_target.is_empty
ensure
    project_set: project_name = a_project
    target_set: target_name = a_target
    not_success_by_default: not is_success
```

### CI_REPORT Contracts

#### make
```eiffel
require
    runner_attached: a_runner /= Void
ensure
    runner_set: runner = a_runner
```

#### save_json_report
```eiffel
require
    path_not_empty: not a_path.is_empty
```

### Class Invariants

#### CI_PROJECT
```eiffel
invariant
    name_attached: name /= Void
    ecf_path_attached: ecf_path /= Void
    targets_attached: targets /= Void
    github_implies_path: is_on_github implies not git_repo_path.is_empty
```

#### CI_RUNNER
```eiffel
invariant
    projects_attached: projects /= Void
    results_attached: results /= Void
    ec_path_attached: ec_path /= Void
```

#### CI_BUILD_RESULT
```eiffel
invariant
    project_name_attached: project_name /= Void
    target_name_attached: target_name /= Void
    non_negative_errors: error_count >= 0
    non_negative_warnings: warning_count >= 0
```
