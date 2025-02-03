local config = require("cfg/git_clone")

local argv = {...}
local argc = #argv

function parse_flags(flags)
	local result = {}

	for _, value in ipairs(flags) do
		local firstCharacter = string.sub(value, 1, 1)

		if firstCharacter == "-" then
			for i = 2, #value do
				local c = string.sub(value, i, i)
				table.insert(result, c)
			end
		else
			error("Invalid argument!")
		end
	end

	return result
end

function install_url(url, path, force)
	if fs.exists(path) then 
		if force == true then 
			fs.delete(path) 
		else 
			return 
		end 
	end

	if shell.run("wget", url, path) == false then error("Failed to install program! Path: " .. path) end
end

function install(base, data, force)
	local url    = base .. data.url
	local path   = data.path
	local config = data.config

	if url  == "" then error("URL may not be empty!")  end
	if path == "" then error("Path may not be empty!") end
	
	install_url(url, path, force)

	if config ~= nil then
		install(base, config, force)
	end
end

function main()
	term.clear()
	term.setCursorPos(1, 1)

	local flags      = parse_flags(argv)
	local repository = config.repository
	local force      = false

	for _, value in ipairs(flags) do
		if value == "f" then force = true end
	end

	for _, value in ipairs(config.required) do
		print("Installing default programs.")
		install(repository, value, force)
	end

	for _, value in ipairs(flags) do
		if value == "o" then
			print("Installing optional programs")
			for _, value in ipairs(config.optional) do
				install(repository, value, force)
			end
		end
	end
	
end

main()
