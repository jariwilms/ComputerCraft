local config = require("/cfg/git_clone")

local argv = {...}
local argc = #argv

function parse_flags(flags)
	local result = {}

	for _, value in ipairs(flags) do
		local firstCharacter = string.sub(value, 1, 1)

		if firstCharacter == "-" then
			for i = 2, #value do
				local character = string.sub(value, i, i)
				table.insert(result, character)
			end
		else
			error("Invalid argument!")
		end
	end

	return result
end

function install_url(url, path, force)
	if fs.exists(path) and force then fs.delete(path)
	else                              return
	end

	io.output("/dev/nil")
	shell.run("wget", url, path)
	io.output(io.stdout)
end

function install(base, data, force)
	local url    = base .. data.url
	local path   = data.path
	local config = data.config

	if url  == "" then error("URL may not be empty!")  end
	if path == "" then error("Path may not be empty!") end
	
	install_url(url, path, force)
	if config ~= nil then install(base, config, force) end
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
		io.write("Installing default programs\n")
		install(repository, value, force)
	end

	for _, value in ipairs(flags) do
		if value == "o" then
			io.write("Installing optional programs\n")

			for _, value in ipairs(config.optional) do
				install(repository, value, force)
			end
		end
	end

	io.write("Intallation complete")
end

main()
