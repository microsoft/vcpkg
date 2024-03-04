if(TARGET firebird)
    return()
endif()

include(CMakeFindDependencyMacro)

add_library(firebird SHARED IMPORTED)

find_library(firebird_LIBRARY_RELEASE
    NAMES firebird
    PATH_SUFFIXES lib
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}"
    NO_DEFAULT_PATH
)

find_library(firebird_LIBRARY_DEBUG
    NAMES firebird
    PATH_SUFFIXES lib
    PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug"
    NO_DEFAULT_PATH
)

set_target_properties(firebird PROPERTIES
    IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include/"
)

if(LINUX)
    set_target_properties(firebird PROPERTIES
        IMPORTED_LOCATION_RELEASE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/libfbclient.so"
        IMPORTED_LOCATION_DEBUG "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/libfbclient.so"
    )
endif()

if(WIN32)
    set_target_properties(firebird PROPERTIES
        IMPORTED_IMPLIB_RELEASE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/fbclient_ms.lib"
        IMPORTED_IMPLIB_DEBUG "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/fbclient_ms.lib"
    )
endif()
