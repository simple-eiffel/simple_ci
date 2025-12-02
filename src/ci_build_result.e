note
	description: "[
		Result of a CI build/test run for a single target.

		Captures:
		- Project and target identification
		- Success/failure status
		- Build output and error messages
		- Timing information
		- Error and warning counts

		Results can be persisted to simple_sql for history tracking.
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_BUILD_RESULT

create
	make,
	make_failed

feature {NONE} -- Initialization

	make (a_project: STRING_32; a_target: STRING_32)
			-- Create result for `a_project' / `a_target'.
		require
			project_not_empty: not a_project.is_empty
			target_not_empty: not a_target.is_empty
		do
			project_name := a_project
			target_name := a_target
			create output.make_empty
			create error_message.make_empty
			create start_time.make_now
			create end_time.make_now
			is_success := False
			error_count := 0
			warning_count := 0
		ensure
			project_set: project_name = a_project
			target_set: target_name = a_target
			not_success_by_default: not is_success
		end

	make_failed (a_project: STRING_32; a_target: STRING_32; a_error: STRING_32)
			-- Create failed result with `a_error' message.
		require
			project_not_empty: not a_project.is_empty
			target_not_empty: not a_target.is_empty
		do
			make (a_project, a_target)
			error_message := a_error
			is_success := False
		ensure
			project_set: project_name = a_project
			target_set: target_name = a_target
			failed: not is_success
			error_set: error_message = a_error
		end

feature -- Access

	project_name: STRING_32
			-- Name of the project

	target_name: STRING_32
			-- Name of the target built

	is_success: BOOLEAN
			-- Did the build succeed?

	output: STRING_32
			-- Full build output

	error_message: STRING_32
			-- Error message if failed

	error_count: INTEGER
			-- Number of errors detected

	warning_count: INTEGER
			-- Number of warnings detected

	start_time: DATE_TIME
			-- When build started

	end_time: DATE_TIME
			-- When build ended

feature -- Derived

	duration_seconds: INTEGER_64
			-- Build duration in seconds
		do
			Result := end_time.relative_duration (start_time).seconds_count
		end

	duration_string: STRING_32
			-- Human-readable duration
		local
			l_secs: INTEGER_64
			l_mins: INTEGER_64
		do
			l_secs := duration_seconds
			if l_secs < 60 then
				Result := l_secs.out + "s"
			else
				l_mins := l_secs // 60
				l_secs := l_secs \\ 60
				Result := l_mins.out + "m " + l_secs.out + "s"
			end
		end

	status_string: STRING_32
			-- "PASS" or "FAIL"
		do
			if is_success then
				Result := "PASS"
			else
				Result := "FAIL"
			end
		end

	summary: STRING_32
			-- One-line summary
		do
			create Result.make (100)
			Result.append ("[")
			Result.append (status_string)
			Result.append ("] ")
			Result.append (project_name)
			Result.append ("/")
			Result.append (target_name)
			Result.append (" (")
			Result.append (duration_string)
			Result.append (")")
			if warning_count > 0 then
				Result.append (" ")
				Result.append (warning_count.out)
				Result.append (" warnings")
			end
			if not is_success and not error_message.is_empty then
				Result.append (" - ")
				Result.append (error_message.substring (1, error_message.count.min (50)))
			end
		end

feature -- Element change

	set_success
			-- Mark build as successful.
		do
			is_success := True
			create end_time.make_now
		ensure
			success: is_success
		end

	set_failed (a_error: STRING_32)
			-- Mark build as failed with `a_error'.
		do
			is_success := False
			error_message := a_error
			create end_time.make_now
		ensure
			failed: not is_success
			error_set: error_message = a_error
		end

	set_output (a_output: STRING_32)
			-- Set build output.
		do
			output := a_output
			parse_output_for_counts
		ensure
			output_set: output = a_output
		end

	set_error_count (a_count: INTEGER)
			-- Set error count.
		require
			non_negative: a_count >= 0
		do
			error_count := a_count
		ensure
			count_set: error_count = a_count
		end

	set_warning_count (a_count: INTEGER)
			-- Set warning count.
		require
			non_negative: a_count >= 0
		do
			warning_count := a_count
		ensure
			count_set: warning_count = a_count
		end

	mark_start
			-- Record start time.
		do
			create start_time.make_now
		end

	mark_end
			-- Record end time.
		do
			create end_time.make_now
		end

feature {NONE} -- Implementation

	parse_output_for_counts
			-- Parse output to count errors and warnings.
		local
			l_lines: LIST [STRING_32]
		do
			error_count := 0
			warning_count := 0
			l_lines := output.split ('%N')
			across l_lines as ic loop
				if ic.has_substring ("Error code:") then
					error_count := error_count + 1
				elseif ic.has_substring ("Warning code:") or ic.has_substring ("Warning:") then
					warning_count := warning_count + 1
				end
			end
		end

invariant
	project_name_attached: project_name /= Void
	target_name_attached: target_name /= Void
	output_attached: output /= Void
	error_message_attached: error_message /= Void
	non_negative_errors: error_count >= 0
	non_negative_warnings: warning_count >= 0

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
