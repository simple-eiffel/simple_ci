note
	description: "[
		Simple CI - Homebrew Continuous Integration for Eiffel Projects.

		Builds and tests all configured projects, generating reports
		that can be consumed by Claude for automated problem resolution.

		Usage:
			simple_ci.exe                    -- Run all projects
			simple_ci.exe --verbose          -- Verbose output
			simple_ci.exe --no-clean         -- Skip clean rebuild
			simple_ci.exe --json             -- Output JSON only
			simple_ci.exe --project NAME     -- Run single project

		Output:
			- Console summary
			- ci_report.json  (for Claude to parse)
			- ci_report.txt   (human-readable)
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

create
	make

feature {NONE} -- Initialization

	make
			-- Run CI.
		local
			l_args: ARGUMENTS_32
		do
			create l_args
			parse_arguments (l_args)

			if show_help then
				print_usage
			else
				run_ci
			end
		end

feature {NONE} -- Arguments

	is_verbose: BOOLEAN
	is_clean: BOOLEAN
	is_finalize: BOOLEAN
	json_only: BOOLEAN
	show_help: BOOLEAN
	selected_projects: ARRAYED_LIST [STRING_32]
	has_error: BOOLEAN

	parse_arguments (a_args: ARGUMENTS_32)
			-- Parse command line arguments.
		local
			i: INTEGER
		do
			is_verbose := False
			is_clean := True
			is_finalize := False
			json_only := False
			show_help := False
			has_error := False
			create selected_projects.make (5)

			from i := 1 until i > a_args.argument_count loop
				if a_args.argument (i) ~ "--verbose" or a_args.argument (i) ~ "-v" then
					is_verbose := True
				elseif a_args.argument (i) ~ "--no-clean" then
					is_clean := False
				elseif a_args.argument (i) ~ "--finalize" then
					is_finalize := True
				elseif a_args.argument (i) ~ "--json" then
					json_only := True
				elseif a_args.argument (i) ~ "--help" or a_args.argument (i) ~ "-h" then
					show_help := True
				elseif a_args.argument (i) ~ "--project" or a_args.argument (i) ~ "-p" then
					-- Can specify multiple projects: -p proj1 -p proj2
					if i < a_args.argument_count then
						i := i + 1
						selected_projects.extend (a_args.argument (i))
					end
				end
				i := i + 1
			end
		end

	print_usage
			-- Print usage information.
		do
			print ("Simple CI - Eiffel Project Build Runner%N")
			print ("=======================================%N%N")
			print ("Usage: simple_ci.exe [options]%N%N")
			print ("Options:%N")
			print ("  --verbose, -v       Show detailed build output%N")
			print ("  --no-clean          Skip clean rebuild (faster, incremental)%N")
			print ("  --finalize          Use finalize mode instead of freeze%N")
			print ("  --json              Output JSON report only (for parsing)%N")
			print ("  -p NAME, --project  Run specific project(s) - can repeat%N")
			print ("  --help, -h          Show this help%N%N")
			print ("Examples:%N")
			print ("  simple_ci.exe                      Run all projects%N")
			print ("  simple_ci.exe -p simple_sql        Run only simple_sql%N")
			print ("  simple_ci.exe -p simple_sql -p simple_web%N")
			print ("                                     Run two projects%N")
			print ("  simple_ci.exe --no-clean -v        Fast incremental verbose%N%N")
			print ("Output Files:%N")
			print ("  ci_report.json    Machine-readable report (for Claude)%N")
			print ("  ci_report.txt     Human-readable report%N")
		end

feature {NONE} -- Execution

	run_ci
			-- Execute CI builds.
		local
			l_runner: CI_RUNNER
			l_config: CI_CONFIG
			l_report: CI_REPORT
			l_all_projects: ARRAYED_LIST [CI_PROJECT]
		do
			create l_config.make

			-- Check for config load errors
			if l_config.has_error then
				print ("Configuration Error: ")
				print (l_config.load_error.to_string_8)
				print ("%N")
				has_error := True
			end

			if not has_error then
				create l_runner.make

				l_runner.set_verbose (is_verbose)
				l_runner.set_clean_build (is_clean)
				l_runner.set_finalize (is_finalize)

				-- Load projects
				if selected_projects.is_empty then
					-- Run all projects
					l_all_projects := l_config.projects
					across l_all_projects as ic loop
						l_runner.add_project (ic)
					end
				else
					-- Run only selected projects
					across selected_projects as ic loop
						if attached l_config.project_by_name (ic) as l_proj then
							l_runner.add_project (l_proj)
						else
							print ("Error: Unknown project '")
							print (ic.to_string_8)
							print ("'%N")
							print ("Available projects:%N")
							l_all_projects := l_config.projects
							across l_all_projects as ic2 loop
								print ("  - ")
								print (ic2.name.to_string_8)
								print ("%N")
							end
							has_error := True
						end
					end
				end

				-- Continue if no errors during project loading
				if not has_error then
					if not json_only then
						print ("Starting CI build...%N")
						print ("Projects: ")
						print (l_runner.projects.count.out)
						if is_finalize then
							print (" (finalize mode)")
						end
						print ("%N%N")
					end

					-- Run builds
					l_runner.run_all

					-- Generate reports
					create l_report.make (l_runner)

					if json_only then
						print (l_report.to_json.to_string_8)
					else
						print (l_report.to_text.to_string_8)
					end

					-- Save reports to files
					l_report.save_json_report (Report_json_path)
					l_report.save_text_report (Report_text_path)

					if not json_only then
						print ("%NReports saved to:%N")
						print ("  ")
						print (Report_json_path)
						print ("%N  ")
						print (Report_text_path)
						print ("%N")
					end

					-- Exit with error code if any builds failed
					if not l_runner.all_passed then
						(create {EXCEPTIONS}).die (1)
					end
				end
			end
		end

feature {NONE} -- Constants

	Report_json_path: STRING = "ci_report.json"
	Report_text_path: STRING = "ci_report.txt"

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
