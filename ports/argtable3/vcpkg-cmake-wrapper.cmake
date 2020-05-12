_find_package(${ARGS})

if(TARGET argtable3 AND NOT TARGET argtable3_static)
    add_library(argtable3_static INTERFACE IMPORTED)
    set_target_properties(argtable3_static PROPERTIES INTERFACE_LINK_LIBRARIES argtable3)
elseif(TARGET argtable3_static AND NOT TARGET argtable3)
    add_library(argtable3 INTERFACE IMPORTED)
    set_target_properties(argtable3 PROPERTIES INTERFACE_LINK_LIBRARIES argtable3_static)
endif()
