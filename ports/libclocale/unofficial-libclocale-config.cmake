if(NOT TARGET unofficial::libclocale::libclocale)
    add_library(unofficial::libclocale::libclocale UNKNOWN IMPORTED)

    set_target_properties(unofficial::libclocale::libclocale PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include"
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
    )

    find_library(VCPKG_LIBCLOCALE_LIBRARY_RELEASE NAMES cerror libclocale PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCLOCALE_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libclocale::libclocale APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libclocale::libclocale PROPERTIES IMPORTED_LOCATION_RELEASE "${VCPKG_LIBCLOCALE_LIBRARY_RELEASE}")
    endif()

    find_library(VCPKG_LIBCLOCALE_LIBRARY_DEBUG NAMES cerror libclocale PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" NO_DEFAULT_PATH)
    if(EXISTS "${VCPKG_LIBCLOCALE_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libclocale::libclocale APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libclocale::libclocale PROPERTIES IMPORTED_LOCATION_DEBUG "${VCPKG_LIBCLOCALE_LIBRARY_DEBUG}")
    endif()
endif()
