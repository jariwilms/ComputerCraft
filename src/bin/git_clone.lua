local config = require("/cfg/git_clone")

local argv = {...}
local argc = #argv

local function parse_flags(flags)
	local map = {}

	for _, value in ipairs(flags) do
		if string.sub(value, 1, 1) == "-" then
			for i = 2, #value do
				map[string.lower(string.sub(value, i, i))] = true
			end
		else error("Invalid argument!")
		end
	end

	return map
end

local function install(base, data, force)
	local url          = base .. data.url
	local path         = data.path
	local dependencies = data.dependencies

	if url  == "" then error("URL may not be empty!")  end
	if path == "" then error("Path may not be empty!") end

	if fs.exists(path) and force then fs.delete(path) end
	shell.run("wget", url, path)

	if dependencies then
		for _, value in ipairs(dependencies) do
			install(base, value, force)
		end
	end
end

local function main()
	term.clear()
	term.setCursorPos(1, 1)

	local flags      = parse_flags(argv)
	local force      = flags["f"]
	local optional   = flags["o"]
	local repository = config.repository

	for _, value in ipairs(config.required) do
		io.write("Installing default programs\n")
		install(repository, value, force)
	end

	if optional then
		io.write("Installing optional programs\n")

		for _, value in ipairs(config.optional) do
			install(repository, value, force)
		end
	end

	io.write("Installation complete\n")
end

main()
