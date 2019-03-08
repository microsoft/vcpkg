_find_package(${ARGS})
set_target_properties(double-conversion::double-conversion PROPERTIES 
   MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
   MAP_IMPORTED_CONFIG_MINSIZEREL Release)
