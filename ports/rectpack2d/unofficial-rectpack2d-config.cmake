if(NOT TARGET unofficial::rectpack2d::rectpack2d)
    add_library(unofficial::rectpack2d::rectpack2d INTERFACE IMPORTED)
    set_target_properties(unofficial::rectpack2d::rectpack2d PROPERTIES
        INTERFACE_COMPILE_FEATURES "cxx_std_17"
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
    )
endif()
