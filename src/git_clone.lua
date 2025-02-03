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
	local force = force or false

	if force == true then if fs.exists(path) then fs.delete(path) end end

	local success = shell.run("wget", url, path)
	if success == false then error("Failed to install program!") end
end

function install(base, data, force)
	local force = force or false

	local url        = base .. data.url
	local identifier = data.identifier
	local config     = data.config

	if url        == "" then error("URL may not be empty!")        end
	if identifier == "" then error("Identifier may not be empty!") end
	
	install_url(url, identifier)
	for _, value in ipairs(config) do
		install(base .. value.url, value.identifier, force)
	end
end

function main()
	term.clear()
	term.setCursorPos(1, 1)

	local flags      = parse_flags(argv)
	local repository = config.repository
	local force      = false

	if #flags == 0 then error("No flags have been supplied!") end

	for _, value in ipairs(flags) do
		if value == "f" then
			force = true
		end
	end

	for _, value in ipairs(flags) do
		if value == "r" then
			local required = config.required

			for _, value in ipairs(required) do
				install(repository, value, force)
			end
		end
		if value == "o" then
			local optional = config.optional

			for _, value in ipairs(optional) do
				install(repository, value, force)
			end
		end
	end
	
end

main()
