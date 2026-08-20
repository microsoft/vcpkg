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
file(STRINGS
    "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/bzlib.h"
    _vcpkg_bzip2_version_line
    REGEX "bzip2/libbzip2 version [0-9]+\\.[^ ]+ of [0-9]+ "
)
string(REGEX REPLACE
    ".* bzip2/libbzip2 version ([0-9]+\\.[^ ]+) of [0-9]+ .*"
    "\\1"
    _vcpkg_bzip2_installed_version
    "${_vcpkg_bzip2_version_line}"
)

if(WIN32
   AND _vcpkg_bzip2_uses_module
   AND NOT TARGET BZip2::BZip2
   AND _vcpkg_bzip2_installed_version
   AND (EXISTS "${_vcpkg_bzip2_runtime_release}" OR EXISTS "${_vcpkg_bzip2_runtime_debug}"))
    set(_vcpkg_bzip2_version_compatible TRUE)
    list(LENGTH ARGS _vcpkg_bzip2_arg_count)
    if(_vcpkg_bzip2_arg_count GREATER 1)
        list(GET ARGS 1 _vcpkg_bzip2_requested_version)
        if(_vcpkg_bzip2_requested_version MATCHES "^[0-9]")
            if(_vcpkg_bzip2_requested_version MATCHES "\\.\\.\\.")
                string(REPLACE "..." ";" _vcpkg_bzip2_version_range "${_vcpkg_bzip2_requested_version}")
                list(GET _vcpkg_bzip2_version_range 0 _vcpkg_bzip2_version_min)
                list(GET _vcpkg_bzip2_version_range 1 _vcpkg_bzip2_version_max)
                if(_vcpkg_bzip2_installed_version VERSION_LESS _vcpkg_bzip2_version_min)
                    set(_vcpkg_bzip2_version_compatible FALSE)
                elseif(_vcpkg_bzip2_version_max MATCHES "^<")
                    string(SUBSTRING "${_vcpkg_bzip2_version_max}" 1 -1 _vcpkg_bzip2_version_max)
                    if(NOT _vcpkg_bzip2_installed_version VERSION_LESS _vcpkg_bzip2_version_max)
                        set(_vcpkg_bzip2_version_compatible FALSE)
                    endif()
                elseif(_vcpkg_bzip2_version_max VERSION_LESS _vcpkg_bzip2_installed_version)
                    set(_vcpkg_bzip2_version_compatible FALSE)
                endif()
            else()
                list(FIND ARGS EXACT _vcpkg_bzip2_exact_index)
                if(_vcpkg_bzip2_exact_index EQUAL -1)
                    if(_vcpkg_bzip2_installed_version VERSION_LESS _vcpkg_bzip2_requested_version)
                        set(_vcpkg_bzip2_version_compatible FALSE)
                    endif()
                elseif(NOT _vcpkg_bzip2_installed_version VERSION_EQUAL _vcpkg_bzip2_requested_version)
                    set(_vcpkg_bzip2_version_compatible FALSE)
                endif()
            endif()
        endif()
    endif()

    if(_vcpkg_bzip2_version_compatible)
        add_library(BZip2::BZip2 SHARED IMPORTED)
        set(_vcpkg_bzip2_can_create_shared_target TRUE)
    endif()
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

unset(_vcpkg_bzip2_arg_count)
unset(_vcpkg_bzip2_can_create_shared_target)
unset(_vcpkg_bzip2_config_index)
unset(_vcpkg_bzip2_exact_index)
unset(_vcpkg_bzip2_installed_version)
unset(_vcpkg_bzip2_requested_version)
unset(_vcpkg_bzip2_runtime_debug)
unset(_vcpkg_bzip2_runtime_release)
unset(_vcpkg_bzip2_version_compatible)
unset(_vcpkg_bzip2_version_max)
unset(_vcpkg_bzip2_version_min)
unset(_vcpkg_bzip2_version_range)
unset(_vcpkg_bzip2_version_line)
unset(_vcpkg_bzip2_module_index)
unset(_vcpkg_bzip2_no_module_index)
unset(_vcpkg_bzip2_uses_module)
