note
	description: "[
		Configuration loader for CI projects.

		Provides factory methods to create the standard set of projects
		with their environment variables and targets.

		This is where you add new projects to the CI build.
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_CONFIG

feature -- Factory

	standard_projects: ARRAYED_LIST [CI_PROJECT]
			-- Create list of all standard projects to build.
		local
			l_project: CI_PROJECT
		do
			create Result.make (10)

			-- simple_json (no dependencies) - ON GITHUB
			create l_project.make ("simple_json", "D:\prod\simple_json\simple_json.ecf")
			l_project.add_target ("simple_json_tests")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_github ("D:\prod\simple_json")
			Result.extend (l_project)

			-- testing_ext (no dependencies on our libs) - ON GITHUB
			create l_project.make ("testing_ext", "D:\prod\testing_ext\testing_ext.ecf")
			l_project.add_target ("testing_ext_tests")
			l_project.set_github ("D:\prod\testing_ext")
			Result.extend (l_project)

			-- simple_process (depends on testing_ext) - ON GITHUB
			create l_project.make ("simple_process", "D:\prod\simple_process\simple_process.ecf")
			l_project.add_target ("simple_process_tests")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_github ("D:\prod\simple_process")
			Result.extend (l_project)

			-- simple_randomizer (depends on testing_ext) - ON GITHUB
			create l_project.make ("simple_randomizer", "D:\prod\simple_randomizer\simple_randomizer.ecf")
			l_project.add_target ("simple_randomizer_tests")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_github ("D:\prod\simple_randomizer")
			Result.extend (l_project)

			-- simple_sql (depends on simple_json, testing_ext) - ON GITHUB
			create l_project.make ("simple_sql", "D:\prod\simple_sql\simple_sql.ecf")
			l_project.add_target ("simple_sql_tests")
			l_project.add_env_var ("SIMPLE_JSON", "D:\prod\simple_json")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_github ("D:\prod\simple_sql")
			Result.extend (l_project)

			-- simple_web (depends on several) - ON GITHUB
			create l_project.make ("simple_web", "D:\prod\simple_web\simple_web.ecf")
			l_project.add_target ("simple_web_tests")
			l_project.add_env_var ("FRAMEWORK", "D:\prod\framework")
			l_project.add_env_var ("SIMPLE_JSON", "D:\prod\simple_json")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.add_env_var ("SIMPLE_SQL", "D:\prod\simple_sql")
			l_project.add_env_var ("SIMPLE_PROCESS", "D:\prod\simple_process")
			l_project.add_env_var ("SIMPLE_RANDOMIZER", "D:\prod\simple_randomizer")
			l_project.set_github ("D:\prod\simple_web")
			Result.extend (l_project)

			-- simple_ai_client (depends on several) - ON GITHUB
			create l_project.make ("simple_ai_client", "D:\prod\simple_ai_client\simple_ai_client.ecf")
			l_project.add_target ("simple_ai_client_tests")
			l_project.add_env_var ("SIMPLE_JSON", "D:\prod\simple_json")
			l_project.add_env_var ("SIMPLE_PROCESS", "D:\prod\simple_process")
			l_project.add_env_var ("SIMPLE_SQL", "D:\prod\simple_sql")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_github ("D:\prod\simple_ai_client")
			Result.extend (l_project)

			-- simple_ec (depends on process, testing_ext) - NOT ON GITHUB
			create l_project.make ("simple_ec", "D:\prod\simple_ec\simple_ec.ecf")
			l_project.add_target ("simple_ec_tests")
			l_project.add_env_var ("TESTING_EXT", "D:\prod\testing_ext")
			l_project.set_not_on_github
			Result.extend (l_project)
		ensure
			result_attached: Result /= Void
			has_projects: Result.count > 0
		end

	project_by_name (a_name: STRING_32): detachable CI_PROJECT
			-- Find project by name from standard projects.
		local
			l_projects: like standard_projects
		do
			l_projects := standard_projects
			across l_projects as ic until Result /= Void loop
				if ic.name ~ a_name then
					Result := ic
				end
			end
		end

feature -- Environment variable definitions

	common_env_vars: HASH_TABLE [STRING_32, STRING_32]
			-- All environment variables needed across projects.
		do
			create Result.make (10)
			Result.put ("D:\prod\testing_ext", "TESTING_EXT")
			Result.put ("D:\prod\simple_json", "SIMPLE_JSON")
			Result.put ("D:\prod\simple_process", "SIMPLE_PROCESS")
			Result.put ("D:\prod\simple_sql", "SIMPLE_SQL")
			Result.put ("D:\prod\simple_web", "SIMPLE_WEB")
			Result.put ("D:\prod\simple_ai_client", "SIMPLE_AI_CLIENT")
			Result.put ("D:\prod\simple_randomizer", "SIMPLE_RANDOMIZER")
			Result.put ("D:\prod\framework", "FRAMEWORK")
		end

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
