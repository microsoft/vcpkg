_find_package(${ARGS})

if(TARGET zyre AND NOT TARGET zyre-static)
    add_library(zyre-static INTERFACE IMPORTED)
    set_target_properties(zyre-static PROPERTIES INTERFACE_LINK_LIBRARIES zyre)
elseif(TARGET zyre-static AND NOT TARGET zyre)
    add_library(zyre INTERFACE IMPORTED)
    set_target_properties(zyre PROPERTIES INTERFACE_LINK_LIBRARIES zyre-static)
endif()
