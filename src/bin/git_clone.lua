local config = require("/cfg/git_clone")
local cmd    = require("/lib/cmd_utils")

local argv = {...}
local argc = #argv

local downloaded = {}



local function install(base, data, force)
	local url          = base .. data.url
	local path         = data.path
	local dependencies = data.dependencies

	if #url  == 0 then error("URL may not be empty!")  end
	if #path == 0 then error("Path may not be empty!") end

	if not downloaded[url] then
		if fs.exists(path) and force then fs.delete(path) end

		shell.run("wget", url, path)
		downloaded[url] = true
	end

	if dependencies then
		for _, value in ipairs(dependencies) do
			install(base, value, force)
		end
	end
end

local function main()
	term.clear()
	term.setCursorPos(1, 1)

	local flags      = cmd.parse_arguments(argv)
	local force      = flags["f"]
	local optional   = flags["o"]
	local repository = config.repository

	for _, value in ipairs(config.required) do
		io.write("Installing default programs...\n")
		install(repository, value, force)
	end

	if optional then
		io.write("Installing optional programs...\n")

		for _, value in ipairs(config.optional) do
			install(repository, value, force)
		end
	end

	io.write("Installation complete.\n")
end

main()
