_find_package(${ARGS})

if(TARGET mimalloc AND NOT TARGET mimalloc-static)
    add_library(mimalloc-static INTERFACE IMPORTED)
    set_target_properties(mimalloc-static PROPERTIES INTERFACE_LINK_LIBRARIES mimalloc)
elseif(TARGET mimalloc-static AND NOT TARGET mimalloc)
    add_library(mimalloc INTERFACE IMPORTED)
    set_target_properties(mimalloc PROPERTIES INTERFACE_LINK_LIBRARIES mimalloc-static)
endif()
