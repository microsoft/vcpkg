message(WARNING "find_package(modbus) is unofficial. libmodbus provides a pkg-config module: libmodbus")

if(NOT TARGET modbus)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
    find_library(Z_VCPKG_MODBUS_RELEASE NAMES modbus PATHS "${VCPKG_IMPORT_PREFIX}/lib" REQUIRED)
    find_library(Z_VCPKG_MODBUS_DEBUG NAMES modbus PATHS "${VCPKG_IMPORT_PREFIX}/debug/lib")
    mark_as_advanced(Z_VCPKG_MODBUS_RELEASE Z_VCPKG_MODBUS_DEBUG)
    add_library(modbus UNKNOWN IMPORTED)
    set_target_properties(modbus PROPERTIES
        IMPORTED_CONFIGURATIONS "Release"
        INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_IMPORT_PREFIX}/include/modbus"
        IMPORTED_LOCATION_RELEASE "${Z_VCPKG_MODBUS_RELEASE}"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
    )
    if(Z_VCPKG_MODBUS_DEBUG)
        set_property(TARGET modbus APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(modbus PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_VCPKG_MODBUS_DEBUG}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        )
    endif()
    if(WIN32)
        set_target_properties(modbus PROPERTIES
            INTERFACE_LINK_LIBRARIES "ws2_32"
        )
    endif()
endif()
