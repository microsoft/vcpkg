_find_package(${ARGS})

if(TARGET flecs::flecs AND NOT TARGET flecs::flecs_static)
    add_library(flecs::flecs_static INTERFACE IMPORTED)
    set_target_properties(flecs::flecs_static PROPERTIES INTERFACE_LINK_LIBRARIES flecs::flecs)
elseif(TARGET flecs::flecs_static AND NOT TARGET flecs::flecs)
    add_library(flecs::flecs INTERFACE IMPORTED)
    set_target_properties(flecs::flecs PROPERTIES INTERFACE_LINK_LIBRARIES flecs::flecs_static)
endif()
