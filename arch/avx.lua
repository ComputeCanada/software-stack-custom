if mode() == "load" then
	local a = loaded_modules()
	for k, v in pairs(a) do
		unload(v["fullName"])
	end
	setenv("RSNT_ARCH","avx")
	for k, v in pairs(a) do
		load(v["fullName"])
	end
end
