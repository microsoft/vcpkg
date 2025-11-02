message(STATUS "find_package(libsocketcan) is unofficial")

if(NOT TARGET libsocketcan)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
    find_library(Z_VCPKG_socketcan_RELEASE NAMES socketcan PATHS "${VCPKG_IMPORT_PREFIX}/lib" REQUIRED)
    find_library(Z_VCPKG_socketcan_DEBUG NAMES socketcan PATHS "${VCPKG_IMPORT_PREFIX}/debug/lib")
    mark_as_advanced(Z_VCPKG_socketcan_RELEASE Z_VCPKG_socketcan_DEBUG)
    add_library(libsocketcan UNKNOWN IMPORTED)
    set_target_properties(libsocketcan PROPERTIES
            IMPORTED_CONFIGURATIONS "Release"
            INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_IMPORT_PREFIX}"
            IMPORTED_LOCATION_RELEASE "${Z_VCPKG_socketcan_RELEASE}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
    )
    if(Z_VCPKG_socketcan_DEBUG)
        set_property(TARGET libsocketcan APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(libsocketcan PROPERTIES
                IMPORTED_LOCATION_DEBUG "${Z_VCPKG_socketcan_DEBUG}"
                IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        )
    endif()
endif()