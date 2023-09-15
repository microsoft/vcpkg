set(Ice_HOME "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
set(Ice_SLICE_DIR "${Ice_HOME}/share/ice/slice")
foreach(z_vcpkg_ice_component IN ITEMS Freeze
                                       Glacier2
                                       Ice
                                       IceBox
                                       IceDB
                                       IceDiscovery
                                       IceGrid
                                       IceLocatorDiscovery
                                       IcePatch
                                       IceSSL
                                       IceStorm
                                       IceUtil
                                       IceXML
                                       Slice
)
    if(z_vcpkg_ice_component IN_LIST ARGS)
        string(TOUPPER "${z_vcpkg_ice_component}" z_vcpkg_ice_cache)
        string(TOLOWER "${z_vcpkg_ice_component}" z_vcpkg_ice_name)
        find_library(Ice_${z_vcpkg_ice_cache}_LIBRARY_RELEASE
            NAMES ${z_vcpkg_ice_component} ${z_vcpkg_ice_component}37
            NAMES_PER_DIR
            PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
            NO_DEFAULT_PATH
        )
        find_library(Ice_${z_vcpkg_ice_cache}_LIBRARY_DEBUG
            NAMES ${z_vcpkg_ice_component}d ${z_vcpkg_ice_component}37d ${z_vcpkg_ice_component} ${z_vcpkg_ice_component}37
            NAMES_PER_DIR
            PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
            NO_DEFAULT_PATH
        )
    endif()
    if("${z_vcpkg_ice_component}++11" IN_LIST ARGS)
        find_library(Ice_${z_vcpkg_ice_cache}++11_LIBRARY_RELEASE
            NAMES ${z_vcpkg_ice_component}++11 ${z_vcpkg_ice_component}37++11
            NAMES_PER_DIR
            PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
            NO_DEFAULT_PATH
        )
        find_library(Ice_${z_vcpkg_ice_cache}++11_LIBRARY_DEBUG
            NAMES ${z_vcpkg_ice_component}++11d ${z_vcpkg_ice_component}37++11d ${z_vcpkg_ice_component}++11 ${z_vcpkg_ice_component}37++11
            NAMES_PER_DIR
            PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib"
            NO_DEFAULT_PATH
        )
    endif()
endforeach()
_find_package(${ARGS})
