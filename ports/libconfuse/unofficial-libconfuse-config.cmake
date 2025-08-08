if(NOT TARGET unofficial::libconfuse::libconfuse)
    add_library(unofficial::libconfuse::libconfuse UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_libconfuse_prefix "${CMAKE_CURRENT_LIST_DIR}" PATH)
    get_filename_component(z_vcpkg_libconfuse_prefix "${z_vcpkg_libconfuse_prefix}" PATH)
    find_library(Z_VCPKG_libconfuse_LIBRARY_RELEASE NAMES confuse PATHS "${z_vcpkg_libconfuse_prefix}/lib" NO_DEFAULT_PATH REQUIRED)
    set_target_properties(unofficial::libconfuse::libconfuse PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_libconfuse_prefix}/include"
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${Z_VCPKG_libconfuse_LIBRARY_RELEASE}"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
    )
    if("@VCPKG_BUILD_TYPE@" STREQUAL "")
        find_library(Z_VCPKG_libconfuse_LIBRARY_DEBUG NAMES libconfuse PATHS "${z_vcpkg_libconfuse_prefix}/debug/lib" NO_DEFAULT_PATH REQUIRED)
        set_property(TARGET unofficial::libconfuse::libconfuse APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::libconfuse::libconfuse PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_libconfuse_LIBRARY_DEBUG}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        )
    endif()
    unset(z_vcpkg_libconfuse_prefix)
endif()
