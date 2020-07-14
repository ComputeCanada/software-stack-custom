local cc_cluster = os.getenv("CC_CLUSTER") or "computecanada"
local arch = "avx2"
local interconnect = os.getenv("RSNT_INTERCONNECT") or ""

if not interconnect or interconnect == "" then
	if cc_cluster == "cedar" then
		interconnect = "omnipath"
	else
		interconnect = "infiniband"
	end
end
local generic_nixpkgs = false
local cuda_driver_version = os.getenv("RSNT_CUDA_DRIVER_VERSION") or ""
if not cuda_driver_version or cuda_driver_version == "" then
	cuda_driver_version = get_installed_cuda_driver_version()
end

assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/nixpkgs/16.09.lua.core"))(arch, interconnect, cuda_driver_version, generic_nixpkgs)
