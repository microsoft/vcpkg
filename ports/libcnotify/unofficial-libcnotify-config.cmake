if(NOT TARGET unofficial::libcnotify::libcnotify)
    add_library(unofficial::libcnotify::libcnotify UNKNOWN IMPORTED)

    set_target_properties(unofficial::libcnotify::libcnotify PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
    )

    find_library(VCPKG_LIBCNOTIFY_LIBRARY_RELEASE NAMES cerror libcnotify PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCNOTIFY_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libcnotify::libcnotify APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libcnotify::libcnotify PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBCNOTIFY_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBCNOTIFY_LIBRARY_DEBUG NAMES cerror libcnotify PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCNOTIFY_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libcnotify::libcnotify APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libcnotify::libcnotify PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBCNOTIFY_LIBRARY_DEBUG}")
    endif()
endif()
