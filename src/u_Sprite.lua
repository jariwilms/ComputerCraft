--Sprite Program

--Includes

--Global

--Images

--Config

--Data

--Class

--Function
--function LoadImage(img)
--	image = img
--end

function DrawImage(x,y,image)
	for i = 0, #image do
		term.setCursorPos(x ,y+i)
		term.write(image[i+1])
	end
end

function DrawImageMonitor(x,y,monitor,image)
	for i = 0, #image do
		monitor.setCursorPos(x,y+i)
		monitor.write(image[i+1])
	end
end

function GetSize(image)
	local x,y=0
	str = image[1]
	x = #str
	y = #image
	return x,y
end 