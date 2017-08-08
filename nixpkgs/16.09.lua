help([[Nixpkgs is a collection of packages for the Nix package manager - Homepage: https://github.com/NixOS/nixpkgs]])
whatis("Description: Nixpkgs is a collection of packages for the Nix package manager - Homepage: https://github.com/NixOS/nixpkgs")

add_property(   "lmod", "sticky")

local root = "/cvmfs/soft.computecanada.ca/nix/var/nix/profiles/16.09"

setenv("NIXUSER_PROFILE", root)
prepend_path("PATH", "/cvmfs/soft.computecanada.ca/custom/bin")
prepend_path("PATH", pathJoin(root, "sbin"))
prepend_path("PATH", pathJoin(root, "bin"))
prepend_path("LIBRARY_PATH", pathJoin(root, "lib"))
prepend_path("CPATH", pathJoin(root, "include"))
prepend_path("MANPATH", pathJoin(root, "share/man"))
prepend_path("ACLOCAL_PATH", pathJoin(root, "share/aclocal"))
prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib/pkgconfig"))
setenv("FONTCONFIG_FILE", pathJoin(root, "etc/fonts/fonts.conf"))
prepend_path("CMAKE_PREFIX_PATH", root)
prepend_path("PYTHONPATH", "/cvmfs/soft.computecanada.ca/custom/python/site-packages")
setenv("PERL5OPT", "-I" .. pathJoin(root, "lib/perl5") .. " -I" .. pathJoin(root, "lib/perl5/site_perl"))
prepend_path("PERL5LIB", pathJoin(root, "lib/perl5/site_perl"))
prepend_path("PERL5LIB", pathJoin(root, "lib/perl5"))
setenv("TZDIR", pathJoin(root,"share/zoneinfo"))
setenv("SSL_CERT_FILE", "/etc/pki/tls/certs/ca-bundle.crt")
setenv("CURL_CA_BUNDLE", "/etc/pki/tls/certs/ca-bundle.crt")
setenv("PAGER", "less -R")
setenv("LESSOPEN", "|" .. pathJoin(root, "bin/lesspipe.sh %s"))
setenv("LOCALE_ARCHIVE", pathJoin(root, "lib/locale/locale-archive"))
-- silence harmless MXM warnings from libmxm
setenv("MXM_LOG_LEVEL", "error")
-- workaround for id issue
prepend_path("LD_LIBRARY_PATH", "/cvmfs/soft.computecanada.ca/nix/lib")

require("os")
-- Define RSNT variables
-- do something only at load time, if not already defined. Otherwise, unloading the module will lose the predefined value if there is one
local cc_cluster = os.getenv("CC_CLUSTER") or "computecanada"
if not os.getenv("RSNT_ARCH") and mode() == "load" then
	if cc_cluster == "cedar" or cc_cluster == "graham" or cc_cluster == "computecanada" then
		setenv("RSNT_ARCH", "avx2")
	end
end
if not os.getenv("RSNT_INTERCONNECT") and mode() == "load" then
	if cc_cluster == "cedar" then
		setenv("RSNT_INTERCONNECT", "omnipath")
	else
		setenv("RSNT_INTERCONNECT", "infiniband")
	end
end


-- also make easybuild and easybuild-generated modules accessible
prepend_path("PATH", "/cvmfs/soft.computecanada.ca/easybuild/bin")
setenv("EASYBUILD_CONFIGFILES", "/cvmfs/soft.computecanada.ca/easybuild/config.cfg")
setenv("EASYBUILD_BUILDPATH", pathJoin("/dev/shm", os.getenv("USER")))

setenv("EBROOTNIXPKGS", root)
setenv("EBVERSIONNIXPKGS", "16.09")

prepend_path("MODULEPATH", "/cvmfs/soft.computecanada.ca/easybuild/modules/2017/Core")
if os.getenv("USER") ~= "ebuser" then
    prepend_path("MODULEPATH", pathJoin(os.getenv("HOME"), ".local/easybuild/modules/2017/Core"))
end
