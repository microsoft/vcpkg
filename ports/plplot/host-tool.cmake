if(NOT TARGET @name@)
    add_executable(@name@ IMPORTED)
    set_target_properties(@name@ PROPERTIES
        IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/@name@@VCPKG_TARGET_EXECUTABLE_SUFFIX@"
    )
endif()
