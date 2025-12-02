note
	description: "[
		Generates CI reports in various formats for consumption by Claude or humans.

		Supports:
		- JSON report (machine-readable, for Claude to parse)
		- Text summary (human-readable console output)
		- File output (save report to disk)

		The JSON format is designed so Claude can easily parse failures
		and take corrective action.
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_REPORT

create
	make

feature {NONE} -- Initialization

	make (a_runner: CI_RUNNER)
			-- Create report from `a_runner' results.
		require
			runner_attached: a_runner /= Void
		do
			runner := a_runner
			create json
		ensure
			runner_set: runner = a_runner
		end

feature -- Access

	runner: CI_RUNNER
			-- The runner with results

feature -- JSON Generation

	to_json: STRING_32
			-- Generate full JSON report.
		local
			l_root: SIMPLE_JSON_OBJECT
			l_results_array: SIMPLE_JSON_ARRAY
			l_result_obj: SIMPLE_JSON_OBJECT
			l_summary: SIMPLE_JSON_OBJECT
		do
			create l_root.make

			-- Summary section
			create l_summary.make
			l_summary.put_integer (runner.total_count, "total").do_nothing
			l_summary.put_integer (runner.pass_count, "passed").do_nothing
			l_summary.put_integer (runner.fail_count, "failed").do_nothing
			l_summary.put_boolean (runner.all_passed, "all_passed").do_nothing
			l_summary.put_integer (runner.total_duration_seconds.to_integer_32, "duration_seconds").do_nothing
			l_summary.put_string (timestamp_string, "timestamp").do_nothing
			l_root.put_object (l_summary, "summary").do_nothing

			-- Results array
			create l_results_array.make
			across runner.results as ic loop
				create l_result_obj.make
				l_result_obj.put_string (ic.project_name, "project").do_nothing
				l_result_obj.put_string (ic.target_name, "target").do_nothing
				l_result_obj.put_boolean (ic.is_success, "success").do_nothing
				l_result_obj.put_integer (ic.error_count, "errors").do_nothing
				l_result_obj.put_integer (ic.warning_count, "warnings").do_nothing
				l_result_obj.put_integer (ic.duration_seconds.to_integer_32, "duration_seconds").do_nothing
				if not ic.is_success then
					l_result_obj.put_string (ic.error_message, "error_message").do_nothing
					-- Include relevant output snippet for failures
					l_result_obj.put_string (extract_failure_context (ic), "failure_context").do_nothing
				end
				l_results_array.add_object (l_result_obj).do_nothing
			end
			l_root.put_array (l_results_array, "results").do_nothing

			-- Failed projects summary for quick access (with git info)
			if runner.fail_count > 0 then
				l_root.put_array (failed_projects_array, "failed_projects").do_nothing
			end

			-- Projects requiring commit/push after fixes
			l_root.put_array (projects_requiring_commit_array, "projects_on_github").do_nothing

			Result := l_root.to_json_string
		end

	to_json_pretty: STRING_32
			-- Generate formatted JSON report.
		do
			Result := to_json
			-- Simple pretty-printing: add newlines after { and , and before }
			Result.replace_substring_all ("{", "{%N  ")
			Result.replace_substring_all ("}", "%N}")
			Result.replace_substring_all (",", ",%N  ")
		end

feature -- Text Generation

	to_text: STRING_32
			-- Generate human-readable text report.
		do
			create Result.make (2000)
			Result.append ("================================================================%N")
			Result.append ("                    CI BUILD REPORT                            %N")
			Result.append ("================================================================%N")
			Result.append ("Timestamp: ")
			Result.append (timestamp_string)
			Result.append ("%N")
			Result.append ("----------------------------------------------------------------%N")
			Result.append ("Total: ")
			Result.append (runner.total_count.out)
			Result.append (" | Passed: ")
			Result.append (runner.pass_count.out)
			Result.append (" | Failed: ")
			Result.append (runner.fail_count.out)
			Result.append ("%N")
			Result.append ("Duration: ")
			Result.append (total_duration_string)
			Result.append ("%N")
			Result.append ("----------------------------------------------------------------%N")

			across runner.results as ic loop
				if ic.is_success then
					Result.append ("[PASS] ")
				else
					Result.append ("[FAIL] ")
				end
				Result.append (ic.project_name)
				Result.append ("/")
				Result.append (ic.target_name)
				if ic.warning_count > 0 then
					Result.append (" (")
					Result.append (ic.warning_count.out)
					Result.append (" warnings)")
				end
				Result.append ("%N")
				if not ic.is_success then
					Result.append ("       -> ")
					Result.append (ic.error_message.substring (1, ic.error_message.count.min (60)))
					Result.append ("%N")
				end
			end

			Result.append ("================================================================%N")
			if runner.all_passed then
				Result.append ("           *** ALL BUILDS PASSED ***%N")
			else
				Result.append ("           *** ")
				Result.append (runner.fail_count.out)
				Result.append (" BUILD(S) FAILED ***%N")
			end
			Result.append ("================================================================%N")
		end

	total_duration_string: STRING_32
			-- Total duration as string.
		local
			l_secs, l_mins: INTEGER_64
		do
			l_secs := runner.total_duration_seconds
			if l_secs < 60 then
				Result := l_secs.out + "s"
			else
				l_mins := l_secs // 60
				l_secs := l_secs \\ 60
				Result := l_mins.out + "m " + l_secs.out + "s"
			end
		end

feature -- File Output

	save_json_report (a_path: READABLE_STRING_GENERAL)
			-- Save JSON report to `a_path'.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_with_name (a_path)
			l_file.open_write
			l_file.put_string (to_json.to_string_8)
			l_file.close
		end

	save_text_report (a_path: READABLE_STRING_GENERAL)
			-- Save text report to `a_path'.
		require
			path_not_empty: not a_path.is_empty
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_with_name (a_path)
			l_file.open_write
			l_file.put_string (to_text.to_string_8)
			l_file.close
		end

feature {NONE} -- Implementation

	json: SIMPLE_JSON
			-- JSON helper

	timestamp_string: STRING_32
			-- Current timestamp as string.
		local
			l_dt: DATE_TIME
		do
			create l_dt.make_now
			Result := l_dt.out
		end

	failed_projects_array: SIMPLE_JSON_ARRAY
			-- Array of failed project/target names with git info.
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_project: detachable CI_PROJECT
		do
			create Result.make
			across runner.results as ic loop
				if not ic.is_success then
					create l_obj.make
					l_obj.put_string (ic.project_name, "project").do_nothing
					l_obj.put_string (ic.target_name, "target").do_nothing
					l_obj.put_string (ic.error_message, "error").do_nothing
					-- Add git info
					l_project := find_project_by_name (ic.project_name)
					if attached l_project as l_proj then
						l_obj.put_boolean (l_proj.is_on_github, "on_github").do_nothing
						if l_proj.is_on_github then
							l_obj.put_string (l_proj.git_repo_path, "git_repo_path").do_nothing
						end
					end
					Result.add_object (l_obj).do_nothing
				end
			end
		end

	projects_requiring_commit_array: SIMPLE_JSON_ARRAY
			-- Array of projects on GitHub that may need commit/push.
		local
			l_obj: SIMPLE_JSON_OBJECT
			l_seen: ARRAYED_LIST [STRING_32]
			l_project: detachable CI_PROJECT
		do
			create Result.make
			create l_seen.make (10)
			across runner.results as ic loop
				if not l_seen.has (ic.project_name) then
					l_seen.extend (ic.project_name)
					l_project := find_project_by_name (ic.project_name)
					if attached l_project as l_proj and then l_proj.is_on_github then
						create l_obj.make
						l_obj.put_string (l_proj.name, "project").do_nothing
						l_obj.put_string (l_proj.git_repo_path, "git_repo_path").do_nothing
						Result.add_object (l_obj).do_nothing
					end
				end
			end
		end

	find_project_by_name (a_name: STRING_32): detachable CI_PROJECT
			-- Find project in runner by name.
		do
			across runner.projects as ic until Result /= Void loop
				if ic.name ~ a_name then
					Result := ic
				end
			end
		end

	extract_failure_context (a_result: CI_BUILD_RESULT): STRING_32
			-- Extract relevant context from failed build output.
			-- Returns the lines around error messages.
		local
			l_lines: LIST [STRING_32]
			l_in_error: BOOLEAN
			l_context_lines: INTEGER
		do
			create Result.make (1000)
			l_lines := a_result.output.split ('%N')
			l_context_lines := 0

			across l_lines as ic loop
				if ic.has_substring ("Error code:") or
				   ic.has_substring ("Could not open") or
				   ic.has_substring ("Cannot find") or
				   ic.has_substring ("fatal error") then
					l_in_error := True
					l_context_lines := 10 -- Capture next 10 lines
				end

				if l_in_error and l_context_lines > 0 then
					Result.append (ic)
					Result.append ("%N")
					l_context_lines := l_context_lines - 1
					if l_context_lines = 0 then
						l_in_error := False
						Result.append ("...%N")
					end
				end
			end

			if Result.count > 2000 then
				Result := Result.substring (1, 2000)
				Result.append ("%N[truncated]")
			end
		end

invariant
	runner_attached: runner /= Void

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
