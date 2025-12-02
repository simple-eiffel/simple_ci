note
	description: "[
		Main CI runner that orchestrates builds across all configured projects.

		Responsibilities:
		- Load project configurations
		- Execute builds for each enabled project/target
		- Collect and report results
		- Optionally persist results to database

		Usage:
			create runner.make
			runner.add_project (project1)
			runner.add_project (project2)
			runner.run_all
			print (runner.report.summary)
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_RUNNER

inherit
	ANY
		redefine
			default_create
		end

create
	default_create,
	make

feature {NONE} -- Initialization

	default_create
			-- Create empty runner.
		do
			make
		end

	make
			-- Initialize runner.
		do
			create projects.make (10)
			create results.make (20)
			create process_helper
			ec_path := detect_ec_path
			is_verbose := False
			is_clean_build := True
			is_finalize := False
		ensure
			no_projects: projects.is_empty
			no_results: results.is_empty
		end

	detect_ec_path: STRING_32
			-- Detect ec.exe path from environment or use default.
		local
			l_env: EXECUTION_ENVIRONMENT
			l_path: detachable STRING_32
		do
			create l_env
			-- Try ISE_EIFFEL first (standard Eiffel env var)
			l_path := l_env.item ("ISE_EIFFEL")
			if attached l_path and then not l_path.is_empty then
				Result := l_path + "\studio\spec\win64\bin\ec.exe"
			else
				-- Try EIFFEL_SRC as fallback
				l_path := l_env.item ("EIFFEL_SRC")
				if attached l_path and then not l_path.is_empty then
					Result := l_path + "\studio\spec\win64\bin\ec.exe"
				else
					-- Use hardcoded default
					Result := Default_ec_path
				end
			end
		ensure
			result_not_empty: not Result.is_empty
		end

feature -- Access

	projects: ARRAYED_LIST [CI_PROJECT]
			-- Projects to build

	results: ARRAYED_LIST [CI_BUILD_RESULT]
			-- Build results from last run

	ec_path: STRING_32
			-- Path to ec.exe compiler

	is_verbose: BOOLEAN
			-- Print detailed output?

	is_clean_build: BOOLEAN
			-- Use -clean flag for fresh builds?

	is_finalize: BOOLEAN
			-- Use -finalize instead of -freeze?

feature -- Statistics

	total_count: INTEGER
			-- Total number of builds attempted
		do
			Result := results.count
		end

	pass_count: INTEGER
			-- Number of successful builds
		do
			across results as ic loop
				if ic.is_success then
					Result := Result + 1
				end
			end
		end

	fail_count: INTEGER
			-- Number of failed builds
		do
			Result := total_count - pass_count
		end

	all_passed: BOOLEAN
			-- Did all builds pass?
		do
			Result := fail_count = 0 and total_count > 0
		end

	total_duration_seconds: INTEGER_64
			-- Total build time in seconds
		do
			across results as ic loop
				Result := Result + ic.duration_seconds
			end
		end

feature -- Element change

	add_project (a_project: CI_PROJECT)
			-- Add `a_project' to the build list.
		require
			project_attached: a_project /= Void
		do
			projects.extend (a_project)
		ensure
			project_added: projects.has (a_project)
		end

	set_ec_path (a_path: STRING_32)
			-- Set compiler path to `a_path'.
		require
			path_not_empty: not a_path.is_empty
		do
			ec_path := a_path
		ensure
			path_set: ec_path = a_path
		end

	set_verbose (a_verbose: BOOLEAN)
			-- Set verbose mode.
		do
			is_verbose := a_verbose
		ensure
			verbose_set: is_verbose = a_verbose
		end

	set_clean_build (a_clean: BOOLEAN)
			-- Set whether to use -clean flag.
		do
			is_clean_build := a_clean
		ensure
			clean_set: is_clean_build = a_clean
		end

	set_finalize (a_finalize: BOOLEAN)
			-- Set whether to use -finalize instead of -freeze.
		do
			is_finalize := a_finalize
		ensure
			finalize_set: is_finalize = a_finalize
		end

feature -- Execution

	run_all
			-- Run all enabled projects and targets.
		do
			results.wipe_out
			across projects as ic loop
				if ic.is_enabled then
					run_project (ic)
				end
			end
		end

	run_project (a_project: CI_PROJECT)
			-- Run all targets for `a_project'.
		require
			project_attached: a_project /= Void
		do
			across a_project.targets as ic loop
				run_target (a_project, ic)
			end
		end

	run_target (a_project: CI_PROJECT; a_target: STRING_32)
			-- Run single `a_target' for `a_project'.
		require
			project_attached: a_project /= Void
			target_not_empty: not a_target.is_empty
		local
			l_result: CI_BUILD_RESULT
			l_cmd: STRING_32
			l_output: STRING_32
		do
			create l_result.make (a_project.name, a_target)
			l_result.mark_start

			if is_verbose then
				print ("Building: " + a_project.name + "/" + a_target + "%N")
			end

			l_cmd := build_command (a_project, a_target)

			if is_verbose then
				print ("  Command: " + l_cmd + "%N")
			end

			l_output := process_helper.output_of_command (l_cmd, Void)
			l_result.set_output (l_output)
			l_result.mark_end

			if output_indicates_success (l_output) then
				l_result.set_success
			else
				l_result.set_failed (extract_error_from_output (l_output))
			end

			results.extend (l_result)

			if is_verbose then
				print ("  " + l_result.summary + "%N")
			end
		end

feature -- Output

	print_summary
			-- Print summary of results to console.
		do
			print ("%N===== CI Build Summary =====%N")
			print ("Total: " + total_count.out + " | ")
			print ("Pass: " + pass_count.out + " | ")
			print ("Fail: " + fail_count.out + "%N")
			print ("Duration: " + format_duration (total_duration_seconds) + "%N")
			print ("%N")

			across results as ic loop
				print (ic.summary + "%N")
			end

			print ("%N")
			if all_passed then
				print ("*** ALL BUILDS PASSED ***%N")
			else
				print ("*** " + fail_count.out + " BUILD(S) FAILED ***%N")
			end
		end

feature {NONE} -- Implementation

	process_helper: SIMPLE_PROCESS_HELPER
			-- Helper for running commands

	build_command (a_project: CI_PROJECT; a_target: STRING_32): STRING_32
			-- Build the ec.exe command for `a_target'.
		do
			create Result.make (500)

			-- Add environment variable prefix
			Result.append (a_project.env_vars_as_prefix)

			-- Add compiler path
			Result.append ("%"")
			Result.append (ec_path)
			Result.append ("%" ")

			-- Add standard flags
			Result.append ("-batch ")
			Result.append ("-config %"")
			Result.append (a_project.ecf_path)
			Result.append ("%" ")
			Result.append ("-target ")
			Result.append (a_target)
			Result.append (" -c_compile")

			if is_finalize then
				Result.append (" -finalize")
			else
				Result.append (" -freeze")
			end

			if is_clean_build then
				Result.append (" -clean")
			end
		end

	output_indicates_success (a_output: STRING_32): BOOLEAN
			-- Does `a_output' indicate a successful build?
		do
			Result := a_output.has_substring ("System Recompiled") or
			          a_output.has_substring ("C compilation completed")
			-- Also check for fatal errors
			if a_output.has_substring ("Error code: V") and not a_output.has_substring ("Obsolete Call") then
				-- Real errors (not just obsolete warnings)
				Result := False
			end
		end

	extract_error_from_output (a_output: STRING_32): STRING_32
			-- Extract first error message from `a_output'.
		local
			l_lines: LIST [STRING_32]
			l_found_error: BOOLEAN
		do
			create Result.make_empty
			l_lines := a_output.split ('%N')
			across l_lines as ic until l_found_error loop
				if ic.has_substring ("Error code:") then
					Result := ic.twin
					l_found_error := True
				elseif ic.has_substring ("Could not open") or
				       ic.has_substring ("Cannot find") or
				       ic.has_substring ("fatal error") then
					Result := ic.twin
					l_found_error := True
				end
			end
			if Result.is_empty then
				Result := "Build failed (check output for details)"
			end
		end

	format_duration (a_seconds: INTEGER_64): STRING_32
			-- Format duration in human-readable form.
		local
			l_mins, l_secs: INTEGER_64
		do
			if a_seconds < 60 then
				Result := a_seconds.out + "s"
			else
				l_mins := a_seconds // 60
				l_secs := a_seconds \\ 60
				Result := l_mins.out + "m " + l_secs.out + "s"
			end
		end

feature {NONE} -- Constants

	Default_ec_path: STRING_32 = "C:\Program Files\Eiffel Software\EiffelStudio 25.02 Standard\studio\spec\win64\bin\ec.exe"

invariant
	projects_attached: projects /= Void
	results_attached: results /= Void
	ec_path_attached: ec_path /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
