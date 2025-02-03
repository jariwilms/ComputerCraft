local config = require("cfg/wget_pb")

local argv = {...}
local argc = #argv

function parse_flags(flags)
	local result = {}

	for index, value in ipairs(flags) do
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

function install_url(url, identifier)
	local success = shell.run("wget", url, identifier)
	if success == false then error("Failed to install program!") end
end

function install(data)
	local base       = data.base
	local url        = base + data.url
	local identifier = data.identifier
	local config     = data.config

	if url        == "" then error("URL may not be empty!")        end
	if identifier == "" then error("Identifier may not be empty!") end
	
	install_url(url, identifier)
	for index, value in ipairs(config) do
		install_url(value.url, "cfg/" + value.identifier)
	end
end

function main()
	term.clear()
	term.setCursorPos(1, 1)

	local flags = parse_flags(argv)

	for index, value in ipairs(flags) do
		if value == "r" then
			local required = config.required

			for index, value in ipairs(required) do
				install(value)
			end
		end
		if value == "o" then
			local optional = config.optional

			for index, value in ipairs(optional) do
				install(value)
			end
		end
	end
	
end

main()
