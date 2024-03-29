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
local generic_nixpkgs = true

if(mode() == "load" and isloaded("StdEnv/2020")) then
	local lang = os.getenv("LANG") or "en"
	if (string.sub(lang,1,2) == "fr") then
		io.stderr:write("Déchargement de StdEnv/2020\n")
	else
		io.stderr:write("Unloading StdEnv/2020\n")
	end
	unload("StdEnv/2020")
end

assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/nixpkgs/16.09.lua.core"))(arch, cpu_vendor_id, interconnect, cuda_driver_version, generic_nixpkgs)
assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/CCconfig.lua"))()
