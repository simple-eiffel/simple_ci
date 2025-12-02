note
	description: "[
		CI Workflow instructions for Claude Code.

		When simple_ci.exe detects failures, Claude should follow this workflow:

		1. RUN CI:
		   simple_ci.exe --verbose

		2. CHECK REPORT:
		   Read ci_report.json to identify failures
		   Look at 'failed_projects' array for quick summary
		   Check 'failure_context' for error details

		3. FIX FAILURES:
		   For each failed project/target:
		   - Read the error_message and failure_context
		   - Identify the root cause
		   - Make necessary code fixes
		   - Do NOT commit yet

		4. VERIFY FIX:
		   Re-run just the failed project:
		   simple_ci.exe --project PROJECT_NAME --verbose

		5. ITERATE:
		   If still failing, go back to step 3
		   If passing, proceed to next failed project

		6. FULL VERIFICATION:
		   Once all individual fixes pass:
		   simple_ci.exe --verbose
		   Confirm all projects pass

		7. COMMIT AND PUSH:
		   For each modified project:
		   - git add changed files
		   - git commit with descriptive message
		   - git push

		8. FINAL REPORT:
		   Run simple_ci.exe one more time
		   Confirm all green
		   Report success to user
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_WORKFLOW

feature -- Workflow Commands

	run_all_command: STRING_32 = "simple_ci.exe --verbose"
			-- Command to run full CI

	run_project_command (a_project: STRING_32): STRING_32
			-- Command to run single project
		do
			Result := "simple_ci.exe --project " + a_project + " --verbose"
		end

	json_report_path: STRING_32 = "ci_report.json"
			-- Path to JSON report for parsing

	text_report_path: STRING_32 = "ci_report.txt"
			-- Path to text report for display

feature -- Workflow Steps

	workflow_steps: ARRAY [STRING_32]
			-- Ordered list of workflow steps
		once
			Result := <<
				"1. Run: simple_ci.exe --verbose",
				"2. Read: ci_report.json for failures",
				"3. Fix: Each failed project's errors",
				"4. Verify: simple_ci.exe --project NAME",
				"5. Iterate: Until project passes",
				"6. Full test: simple_ci.exe --verbose",
				"7. Commit: git add/commit/push each project",
				"8. Confirm: Final CI run all green"
			>>
		end

feature -- Instructions for Claude

	claude_instructions: STRING_32
			-- Instructions for Claude when CI fails
		do
			create Result.make (2000)
			Result.append ("=== CI FAILURE DETECTED ===%N%N")
			Result.append ("To fix the failures, follow this workflow:%N%N")
			Result.append ("1. Parse ci_report.json to identify failed projects%N")
			Result.append ("2. For each failure in 'failed_projects':%N")
			Result.append ("   a. Read the 'failure_context' for error details%N")
			Result.append ("   b. Locate and fix the source of the error%N")
			Result.append ("   c. Run: simple_ci.exe --project PROJECT_NAME%N")
			Result.append ("   d. Repeat until that project passes%N%N")
			Result.append ("3. Once all individual fixes pass:%N")
			Result.append ("   Run: simple_ci.exe --verbose%N")
			Result.append ("   Confirm ALL projects pass%N%N")
			Result.append ("4. Commit and push changes:%N")
			Result.append ("   For each modified project repo:%N")
			Result.append ("   - git add [changed files]%N")
			Result.append ("   - git commit -m 'Fix: [description]'%N")
			Result.append ("   - git push%N%N")
			Result.append ("5. Run final CI check to confirm all green%N")
		end

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
