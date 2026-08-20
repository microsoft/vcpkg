set(_vcpkg_bzip2_runtime_release "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/bin/bz2.dll")
set(_vcpkg_bzip2_runtime_debug "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/bin/bz2d.dll")
set(_vcpkg_bzip2_can_create_shared_target FALSE)
list(FIND ARGS CONFIG _vcpkg_bzip2_config_index)
list(FIND ARGS NO_MODULE _vcpkg_bzip2_no_module_index)
list(FIND ARGS MODULE _vcpkg_bzip2_module_index)
set(_vcpkg_bzip2_uses_module TRUE)
if(NOT _vcpkg_bzip2_config_index EQUAL -1
   OR NOT _vcpkg_bzip2_no_module_index EQUAL -1
   OR (CMAKE_FIND_PACKAGE_PREFER_CONFIG AND _vcpkg_bzip2_module_index EQUAL -1))
    set(_vcpkg_bzip2_uses_module FALSE)
endif()

if(WIN32
   AND _vcpkg_bzip2_uses_module
   AND NOT TARGET BZip2::BZip2
   AND (EXISTS "${_vcpkg_bzip2_runtime_release}" OR EXISTS "${_vcpkg_bzip2_runtime_debug}"))
    add_library(BZip2::BZip2 SHARED IMPORTED)
    set(_vcpkg_bzip2_can_create_shared_target TRUE)
endif()

_find_package(${ARGS})

if(_vcpkg_bzip2_can_create_shared_target AND BZIP2_FOUND)
    set_property(TARGET BZip2::BZip2 PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${BZIP2_INCLUDE_DIRS}")

    if(BZIP2_LIBRARY_RELEASE AND EXISTS "${_vcpkg_bzip2_runtime_release}")
        set_property(TARGET BZip2::BZip2 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(BZip2::BZip2 PROPERTIES
            IMPORTED_IMPLIB_RELEASE "${BZIP2_LIBRARY_RELEASE}"
            IMPORTED_LOCATION_RELEASE "${_vcpkg_bzip2_runtime_release}"
        )
    endif()

    if(BZIP2_LIBRARY_DEBUG AND EXISTS "${_vcpkg_bzip2_runtime_debug}")
        set_property(TARGET BZip2::BZip2 APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(BZip2::BZip2 PROPERTIES
            IMPORTED_IMPLIB_DEBUG "${BZIP2_LIBRARY_DEBUG}"
            IMPORTED_LOCATION_DEBUG "${_vcpkg_bzip2_runtime_debug}"
        )
    endif()
endif()

unset(_vcpkg_bzip2_can_create_shared_target)
unset(_vcpkg_bzip2_config_index)
unset(_vcpkg_bzip2_runtime_debug)
unset(_vcpkg_bzip2_runtime_release)
unset(_vcpkg_bzip2_module_index)
unset(_vcpkg_bzip2_no_module_index)
unset(_vcpkg_bzip2_uses_module)
