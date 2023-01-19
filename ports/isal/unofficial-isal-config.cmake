if(NOT TARGET unofficial::isal::isal)
    add_library(unofficial::isal::isal UNKNOWN IMPORTED)
    get_filename_component(z_vcpkg_isal_prefix "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(z_vcpkg_isal_prefix "${z_vcpkg_isal_prefix}" PATH)
    get_filename_component(z_vcpkg_isal_prefix "${z_vcpkg_isal_prefix}" PATH)
    find_library(Z_VCPKG_ISAL_LIBRARY_RELEASE NAMES isal isa-l_static isa-l PATHS "${z_vcpkg_isal_prefix}/lib" NO_DEFAULT_PATH REQUIRED)
    set_target_properties(unofficial::isal::isal PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${z_vcpkg_isal_prefix}/include"
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${Z_VCPKG_ISAL_LIBRARY_RELEASE}"
    )
    if("@VCPKG_BUILD_TYPE@" STREQUAL "")
        find_library(Z_VCPKG_ISAL_LIBRARY_DEBUG NAMES isal isa-l_static isa-l PATHS "${z_vcpkg_isal_prefix}/debug/lib" NO_DEFAULT_PATH REQUIRED)
        set_property(TARGET unofficial::isal::isal APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::isal::isal PROPERTIES IMPORTED_LOCATION_DEBUG "${Z_VCPKG_ISAL_LIBRARY_DEBUG}")
    endif()
    unset(z_vcpkg_isal_prefix)
endif()
