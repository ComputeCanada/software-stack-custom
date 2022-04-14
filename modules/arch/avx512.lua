if (mode() ~= "spider") then
	prepend_path("MODULEPATH","/cvmfs/soft.computecanada.ca/custom/modules-avx512")
	setenv("EBVERSIONARCH","avx512")
end
