if os.getenv("CC_CLUSTER") == "beluga" or os.getenv("CC_CLUSTER") == "niagara" then
        module_version("StdEnv/2018.3","default")
else
        module_version("StdEnv/2016.4","default")
end
