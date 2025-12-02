note
	description: "[
		Represents a project to be built and tested by the CI runner.

		Each project has:
		- A name for identification
		- A path to the ECF configuration file
		- One or more targets to build/test
		- Required environment variables

		Example:
			create project.make ("simple_sql", "D:\prod\simple_sql\simple_sql.ecf")
			project.add_target ("simple_sql_tests")
			project.add_env_var ("SIMPLE_JSON", "D:\prod\simple_json")
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_PROJECT

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING_32; a_ecf_path: STRING_32)
			-- Create project with `a_name' and `a_ecf_path'.
		require
			name_not_empty: not a_name.is_empty
			ecf_path_not_empty: not a_ecf_path.is_empty
		do
			name := a_name
			ecf_path := a_ecf_path
			create targets.make (5)
			create environment_variables.make (10)
			is_enabled := True
			is_on_github := False
			create git_repo_path.make_empty
		ensure
			name_set: name = a_name
			ecf_path_set: ecf_path = a_ecf_path
			enabled_by_default: is_enabled
			not_on_github_by_default: not is_on_github
		end

feature -- Access

	name: STRING_32
			-- Project name for identification

	ecf_path: STRING_32
			-- Full path to the ECF configuration file

	targets: ARRAYED_LIST [STRING_32]
			-- List of targets to build/test

	environment_variables: HASH_TABLE [STRING_32, STRING_32]
			-- Environment variables needed (value -> name)

	is_enabled: BOOLEAN
			-- Is this project enabled for building?

	is_on_github: BOOLEAN
			-- Is this project tracked in a GitHub repository?
			-- If True, changes should be committed and pushed after fixes.

	git_repo_path: STRING_32
			-- Path to the git repository root (may differ from ECF location)

feature -- Element change

	add_target (a_target: STRING_32)
			-- Add `a_target' to the build list.
		require
			target_not_empty: not a_target.is_empty
		do
			targets.extend (a_target)
		ensure
			target_added: targets.has (a_target)
		end

	add_env_var (a_name: STRING_32; a_value: STRING_32)
			-- Add environment variable `a_name' with `a_value'.
		require
			name_not_empty: not a_name.is_empty
		do
			environment_variables.put (a_value, a_name)
		ensure
			var_added: environment_variables.has (a_name)
		end

	set_enabled (a_enabled: BOOLEAN)
			-- Set whether project is enabled.
		do
			is_enabled := a_enabled
		ensure
			enabled_set: is_enabled = a_enabled
		end

	disable
			-- Disable this project.
		do
			is_enabled := False
		ensure
			disabled: not is_enabled
		end

	enable
			-- Enable this project.
		do
			is_enabled := True
		ensure
			enabled: is_enabled
		end

	set_github (a_repo_path: STRING_32)
			-- Mark project as on GitHub with repo at `a_repo_path'.
		require
			path_not_empty: not a_repo_path.is_empty
		do
			is_on_github := True
			git_repo_path := a_repo_path
		ensure
			on_github: is_on_github
			path_set: git_repo_path = a_repo_path
		end

	set_not_on_github
			-- Mark project as not tracked on GitHub.
		do
			is_on_github := False
			create git_repo_path.make_empty
		ensure
			not_on_github: not is_on_github
		end

feature -- Query

	target_count: INTEGER
			-- Number of targets
		do
			Result := targets.count
		end

	has_target (a_target: STRING_32): BOOLEAN
			-- Does project have `a_target'?
		do
			Result := targets.has (a_target)
		end

	env_vars_as_prefix: STRING_32
			-- Format environment variables for command prefix.
			-- Returns: VAR1="value1" VAR2="value2" ...
		local
			l_keys: ARRAY [STRING_32]
			i: INTEGER
		do
			create Result.make (200)
			l_keys := environment_variables.current_keys
			from i := l_keys.lower until i > l_keys.upper loop
				Result.append (l_keys [i])
				Result.append ("=%"")
				if attached environment_variables.item (l_keys [i]) as l_val then
					Result.append (l_val)
				end
				Result.append ("%" ")
				i := i + 1
			end
		end

	requires_commit: BOOLEAN
			-- Does this project need commit/push after fixes?
		do
			Result := is_on_github
		end

invariant
	name_attached: name /= Void
	ecf_path_attached: ecf_path /= Void
	targets_attached: targets /= Void
	env_vars_attached: environment_variables /= Void
	git_path_attached: git_repo_path /= Void
	github_implies_path: is_on_github implies not git_repo_path.is_empty

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
