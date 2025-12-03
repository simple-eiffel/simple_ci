note
	description: "[
		Configuration loader for CI projects.

		Loads project definitions from config.json file located
		in the same directory as the executable.

		JSON format:
		{
			"projects": [
				{
					"name": "project_name",
					"ecf": "path/to/project.ecf",
					"test_target": "project_tests",
					"github": "path/to/repo" or null,
					"env_vars": { "VAR": "value", ... }
				}
			]
		}
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	CI_CONFIG

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize and load configuration.
		do
			create projects_cache.make (10)
			create load_error.make_empty
			load_config
		end

feature -- Access

	projects: ARRAYED_LIST [CI_PROJECT]
			-- All configured projects.
		do
			Result := projects_cache
		end

	project_by_name (a_name: STRING_32): detachable CI_PROJECT
			-- Find project by name.
		do
			across projects as ic until Result /= Void loop
				if ic.name.same_string (a_name) then
					Result := ic
				end
			end
		end

	available_project_names: ARRAYED_LIST [STRING_32]
			-- List of all project names.
		do
			create Result.make (projects.count)
			across projects as ic loop
				Result.extend (ic.name)
			end
		end

	has_error: BOOLEAN
			-- Did loading fail?
		do
			Result := not load_error.is_empty
		end

	load_error: STRING_32
			-- Error message if loading failed.

feature {NONE} -- Implementation

	projects_cache: ARRAYED_LIST [CI_PROJECT]
			-- Cached project list.

	load_config
			-- Load configuration from JSON file.
		local
			l_file: PLAIN_TEXT_FILE
			l_content: STRING
			l_json: SIMPLE_JSON
			l_config_path: STRING_32
		do
			l_config_path := config_file_path
			create l_file.make_with_name (l_config_path)

			if not l_file.exists then
				load_error := "Config file not found: " + l_config_path
			else
				l_file.open_read
				l_file.read_stream (l_file.count.max (1))
				l_content := l_file.last_string
				l_file.close

				create l_json
				if attached l_json.parse (l_content) as l_value then
					if attached l_value.as_object as l_obj then
						parse_config (l_obj)
					else
						load_error := "Config file must contain a JSON object"
					end
				else
					if l_json.has_errors then
						load_error := "Invalid JSON in config file: " + l_json.errors_as_string
					else
						load_error := "Invalid JSON in config file"
					end
				end
			end
		end

	parse_config (a_config: SIMPLE_JSON_OBJECT)
			-- Parse configuration object.
		local
			l_arr: SIMPLE_JSON_ARRAY
			i: INTEGER
		do
			if attached a_config.array_item ("projects") as l_projects then
				l_arr := l_projects
				from i := 1 until i > l_arr.count loop
					if attached l_arr.item (i).as_object as l_proj_obj then
						parse_project (l_proj_obj)
					end
					i := i + 1
				end
			else
				load_error := "Config file missing 'projects' array"
			end
		end

	parse_project (a_obj: SIMPLE_JSON_OBJECT)
			-- Parse a single project from JSON.
		local
			l_project: CI_PROJECT
			l_name, l_ecf, l_target, l_github: STRING_32
			l_env_obj: SIMPLE_JSON_OBJECT
		do
			if attached a_obj.string_item ("name") as n then
				l_name := n
			else
				l_name := "unknown"
			end

			if attached a_obj.string_item ("ecf") as e then
				l_ecf := e
			else
				l_ecf := ""
			end

			if not l_name.same_string ("unknown") and not l_ecf.is_empty then
				create l_project.make (l_name, l_ecf)

				-- Add test target
				if attached a_obj.string_item ("test_target") as t then
					l_target := t
					l_project.add_target (l_target)
				end

				-- Set GitHub repo path (check if key exists and value is not null)
				if a_obj.has_key ("github") then
					if attached a_obj.string_item ("github") as g then
						l_github := g
						l_project.set_github (l_github)
					else
						-- github key exists but value is null
						l_project.set_not_on_github
					end
				else
					l_project.set_not_on_github
				end

				-- Add environment variables
				if attached a_obj.object_item ("env_vars") as l_env then
					l_env_obj := l_env
					across l_env_obj.keys as k loop
						if attached l_env_obj.string_item (k) as v then
							l_project.add_env_var (k, v)
						end
					end
				end

				projects_cache.extend (l_project)
			end
		end

	config_file_path: STRING_32
			-- Path to config.json (same directory as executable).
		local
			l_path: PATH
			l_args: ARGUMENTS_32
		do
			create l_args
			if attached l_args.command_name as l_cmd then
				create l_path.make_from_string (l_cmd)
				if attached l_path.parent as l_parent then
					Result := l_parent.name + "\config.json"
				else
					Result := "config.json"
				end
			else
				Result := "config.json"
			end
		end

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"

end
