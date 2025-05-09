if (mode() ~= "spider") then
	local custom_root = os.getenv("RSNT_CUSTOM_ROOT") or "/cvmfs/soft.computecanada.ca/custom"
	prepend_path("MODULEPATH", custom_root .. "/modules-avx")
	setenv("EBVERSIONARCH","avx")
end
