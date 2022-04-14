if (mode() ~= "spider") then
	prepend_path("MODULEPATH","/cvmfs/soft.computecanada.ca/custom/modules-sse3")
	setenv("EBVERSIONARCH","sse3")
end
