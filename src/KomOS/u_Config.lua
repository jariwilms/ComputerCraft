--Config reader

--Globals

--Class
local ConfigReader = {data = {
		currentPath = "none",
	}}
	
function ConfigReader.__init__ (data)
  local self = {data=data}
  setmetatable (self, {__index=ConfigReader})
  return self
end

setmetatable (ConfigReader, {__call=ConfigReader.__init__})

--functions
function ConfigReader:setPath(path)
	local success = fs.exists(path)
	if success then
		self.data.currentPath = path
	else
		error("config file does not extist")
	end
	return success
end

function ConfigReader:getData (member)
	local line = ""
	local config = fs.open(self.data.currentPath, "r")
	while line do
		line = config.readLine()
		if line ~= nil then
			if member == string.match(line, member) then
				config.close()
				local ReturnVal, final = string.find(line, ": ")
				return string.sub(line, final + 1)
			end
		end
	end
	error("did not find variable")
	return 0
end

function ConfigReader:getString (member)
	local line = ""
	local config = fs.open(self.data.currentPath, "r")
	while line do
		line = config.readLine()
		if member == string.match(line, member) then
			config.close()
			local newStr, replaced = string.gsub(line, member..": " , "")
			return newStr
		end
	end
	error("did not find variable")
	return 0
end

return ConfigReader