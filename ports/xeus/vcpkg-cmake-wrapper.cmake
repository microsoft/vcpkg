_find_package(${ARGS})

if(TARGET xeus AND NOT TARGET xeus_static)
    add_library(xeus_static INTERFACE IMPORTED)
    set_target_properties(xeus_static PROPERTIES INTERFACE_LINK_LIBRARIES xeus)
elseif(TARGET xeus_static AND NOT TARGET xeus)
    add_library(xeus INTERFACE IMPORTED)
    set_target_properties(xeus PROPERTIES INTERFACE_LINK_LIBRARIES xeus_static)
endif()
