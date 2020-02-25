_find_package(${ARGS})

if(TARGET octomap AND NOT TARGET octomap-static)
    add_library(octomap-static INTERFACE IMPORTED)
    set_target_properties(octomap-static PROPERTIES INTERFACE_LINK_LIBRARIES "octomap")    

    add_library(octomath-static INTERFACE IMPORTED)
    set_target_properties(octomath-static PROPERTIES INTERFACE_LINK_LIBRARIES "octomath")
elseif(TARGET octomap-static AND NOT TARGET octomap)
    add_library(octomap INTERFACE IMPORTED)
    set_target_properties(octomap PROPERTIES INTERFACE_LINK_LIBRARIES "octomap-static")
    
    add_library(octomath INTERFACE IMPORTED)
    set_target_properties(octomath PROPERTIES INTERFACE_LINK_LIBRARIES "octomath-static")
endif()
