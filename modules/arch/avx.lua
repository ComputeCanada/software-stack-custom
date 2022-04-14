if (mode() ~= "spider") then
	prepend_path("MODULEPATH","/cvmfs/soft.computecanada.ca/custom/modules-avx")
	setenv("EBVERSIONARCH","avx")
end
