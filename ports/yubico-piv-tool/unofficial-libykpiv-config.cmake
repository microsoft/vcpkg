include(CMakeFindDependencyMacro)

find_dependency(OpenSSL)
find_dependency(ZLIB)

if(NOT TARGET unofficial::libykpiv::ykpiv)
    add_library(unofficial::libykpiv::ykpiv UNKNOWN IMPORTED)

    find_library(_unofficial_ykpiv_library_release
        NAMES ykpiv ykpiv_static libykpiv
        PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib"
        NO_DEFAULT_PATH
    )
    find_library(_unofficial_ykpiv_library_debug
        NAMES ykpiv ykpiv_static libykpiv
        PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib"
        NO_DEFAULT_PATH
    )

    # Transitive dependencies
    set(_ykpiv_link_libs OpenSSL::Crypto ZLIB::ZLIB)
    if(WIN32)
        list(APPEND _ykpiv_link_libs winscard ws2_32)
    elseif(APPLE)
        list(APPEND _ykpiv_link_libs "-framework PCSC")
    else()
        find_library(_unofficial_ykpiv_pcsclite pcsclite)
        if(NOT _unofficial_ykpiv_pcsclite)
            message(FATAL_ERROR "libpcsclite not found.")
        endif()
        list(APPEND _ykpiv_link_libs ${_unofficial_ykpiv_pcsclite})
    endif()

    set_target_properties(unofficial::libykpiv::ykpiv PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
        INTERFACE_LINK_LIBRARIES "${_ykpiv_link_libs}"
    )

    if(_unofficial_ykpiv_library_release)
        set_property(TARGET unofficial::libykpiv::ykpiv APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(unofficial::libykpiv::ykpiv PROPERTIES
            IMPORTED_LOCATION_RELEASE "${_unofficial_ykpiv_library_release}"
        )
    endif()

    if(_unofficial_ykpiv_library_debug)
        set_property(TARGET unofficial::libykpiv::ykpiv APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::libykpiv::ykpiv PROPERTIES
            IMPORTED_LOCATION_DEBUG "${_unofficial_ykpiv_library_debug}"
        )
    endif()

    unset(_ykpiv_link_libs)
endif()
