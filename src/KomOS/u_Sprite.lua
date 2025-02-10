--Sprite Program

--Includes

--Global

--Images

--Config

--Data

--Class

--Function
local SpriteRender = {}

function SpriteRender.DrawImage(x,y,image)
	for i = 0, #image-1 do
		term.setCursorPos(x ,y+i)
		term.write(image[i+1])
	end
end

function SpriteRender.DrawImageMonitor(x,y,monitor,image)
	for i = 0, #image-1 do
		monitor.setCursorPos(x,y+i)
		monitor.write(image[i+1])
	end
end

function SpriteRender.GetSize(image)
	local x,y = 0,0
	local str = image[1]
	x = #str
	y = #image
	return x,y
end

return SpriteRender