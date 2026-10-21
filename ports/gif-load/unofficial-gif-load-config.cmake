if(NOT TARGET unofficial::gif-load::gif-load)
    add_library(unofficial::gif-load::gif-load INTERFACE IMPORTED)
    set_target_properties(unofficial::gif-load::gif-load PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include")
endif()
