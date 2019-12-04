_find_package(${ARGS})

if(TARGET czmq AND NOT TARGET czmq-static)
    add_library(czmq-static INTERFACE IMPORTED)
    set_target_properties(czmq-static PROPERTIES INTERFACE_LINK_LIBRARIES czmq)
elseif(TARGET czmq-static AND NOT TARGET czmq)
    add_library(czmq INTERFACE IMPORTED)
    set_target_properties(czmq PROPERTIES INTERFACE_LINK_LIBRARIES czmq-static)
endif()
