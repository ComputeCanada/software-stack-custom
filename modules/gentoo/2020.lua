require("SitePackage")

local cc_cluster = os.getenv("CC_CLUSTER") or "computecanada"
local arch = os.getenv("RSNT_ARCH") or ""
local interconnect = os.getenv("RSNT_INTERCONNECT") or ""
local cpu_vendor_id = os.getenv("RSNT_CPU_VENDOR_ID") or ""

if not arch or arch == "" then
	if cc_cluster == "cedar" or cc_cluster == "graham" then
		arch = "avx2"
	else
		arch = get_highest_supported_architecture()
	end
end
if not cpu_vendor_id or cpu_vendor_id == "" then
	cpu_vendor_id = get_cpu_vendor_id()
end
if not interconnect or interconnect == "" then
	if cc_cluster == "cedar" then
		interconnect = "omnipath"
	else
		interconnect = get_interconnect()
	end
end
local cuda_driver_version = os.getenv("RSNT_CUDA_DRIVER_VERSION") or ""
if not cuda_driver_version or cuda_driver_version == "" then
	cuda_driver_version = get_installed_cuda_driver_version()
end

assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/gentoo/2020.lua.core"))(arch, cpu_vendor_id, interconnect, cuda_driver_version)
conflict("StdEnv/2016.4")
conflict("StdEnv/2018.3")
