function io.redirect(path, func, ...)
    io.output(path)
	local result = func(...)
	io.output(io.stdout)

	return result
end
