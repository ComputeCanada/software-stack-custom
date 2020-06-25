local cc_cluster = os.getenv("CC_CLUSTER") or "computecanada"
local arch = "sse3"
local interconnect = os.getenv("RSNT_INTERCONNECT") or ""

if not interconnect or interconnect == "" then
	if cc_cluster == "cedar" then
		interconnect = "omnipath"
	else
		interconnect = "infiniband"
	end
end
local generic_nixpkgs = false

assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/nixpkgs/16.09.lua.core"))(arch, interconnect, generic_nixpkgs)
assert(loadfile("/cvmfs/soft.computecanada.ca/custom/modules/CCconfig.lua"))()
