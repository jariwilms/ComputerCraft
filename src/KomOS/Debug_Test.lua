local chests = {peripheral.find("minecraft:chest")}

print(tostring(#chests))

for i, chest in ipairs(chests) do
    print(peripheral.getType(chest))
end

local modem = peripheral.find("modem")
local networkchests = modem.hasTypeRemote("", "minecraft:chest")
print(textutils.serialise(networkchests))