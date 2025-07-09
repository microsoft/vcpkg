include(CMakeFindDependencyMacro)

if(NOT TARGET meojson::meojson)
    add_library(meojson::meojson INTERFACE IMPORTED)
    set_target_properties(meojson::meojson PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
    )
endif()