if (mode() == "load") then
   local required = false
   local activeA = loaded_modules()

   for i = 1,#activeA do
      unload(activeA[i].userName)
   end
   setenv("RSNT_ARCH","avx")
   for i = 1,#activeA do
      mgrload(required, activeA[i])
   end
end
