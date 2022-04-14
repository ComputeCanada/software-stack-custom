if (mode() ~= "spider") then
	prepend_path("MODULEPATH","/cvmfs/soft.computecanada.ca/custom/modules-avx2")
	setenv("EBVERSIONARCH","avx2")
end
