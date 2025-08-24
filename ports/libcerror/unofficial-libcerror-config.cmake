if(NOT TARGET unofficial::libcerror::libcerror)
    add_library(unofficial::libcerror::libcerror UNKNOWN IMPORTED)

    set_target_properties(unofficial::libcerror::libcerror PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
    )

    find_library(VCPKG_LIBCERROR_LIBRARY_RELEASE NAMES cerror libcerror PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCERROR_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libcerror::libcerror APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libcerror::libcerror PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBCERROR_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBCERROR_LIBRARY_DEBUG NAMES cerror libcerror PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCERROR_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libcerror::libcerror APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libcerror::libcerror PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBCERROR_LIBRARY_DEBUG}")
    endif()
endif()
