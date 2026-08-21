if(NOT TARGET unofficial::libcdatetime::libcdatetime)
    add_library(unofficial::libcdatetime::libcdatetime UNKNOWN IMPORTED)

    set_target_properties(unofficial::libcdatetime::libcdatetime PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
    )

    find_library(VCPKG_LIBCDATETIME_LIBRARY_RELEASE NAMES cerror libcdatetime PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCDATETIME_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libcdatetime::libcdatetime APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libcdatetime::libcdatetime PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBCDATETIME_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBCDATETIME_LIBRARY_DEBUG NAMES cerror libcdatetime PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCDATETIME_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libcdatetime::libcdatetime APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libcdatetime::libcdatetime PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBCDATETIME_LIBRARY_DEBUG}")
    endif()
endif()
