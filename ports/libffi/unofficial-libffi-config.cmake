if(NOT TARGET unofficial::libffi::libffi)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
    find_library(VCPKG_LIBFFI_LIBRARY_RELEASE NAMES ffi PATHS "${VCPKG_IMPORT_PREFIX}/lib" REQUIRED)
    find_library(VCPKG_LIBFFI_LIBRARY_DEBUG NAMES ffi PATHS "${VCPKG_IMPORT_PREFIX}/debug/lib")
    mark_as_advanced(VCPKG_LIBFFI_LIBRARY_RELEASE VCPKG_LIBFFI_LIBRARY_DEBUG)
    add_library(unofficial::libffi::libffi UNKNOWN IMPORTED)
    set_target_properties(unofficial::libffi::libffi PROPERTIES
        IMPORTED_CONFIGURATIONS "Release"
        INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_IMPORT_PREFIX}/include"
        IMPORTED_LOCATION_RELEASE "${VCPKG_LIBFFI_LIBRARY_RELEASE}"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
    )
    if(VCPKG_LIBFFI_LIBRARY_DEBUG)
        set_property(TARGET unofficial::libffi::libffi APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(unofficial::libffi::libffi PROPERTIES
            IMPORTED_LOCATION_DEBUG "${VCPKG_LIBFFI_LIBRARY_DEBUG}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        )
    endif()
endif()
