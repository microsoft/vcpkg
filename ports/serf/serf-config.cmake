include(CMakeFindDependencyMacro)

if(NOT TARGET unofficial:SERF:serf)
    add_library(unofficial:SERF:serf UNKNOWN IMPORTED)

    find_dependency(OpenSSL)
    find_dependency(ZLIB)
    find_dependency(unofficial-apr)

    find_path(SERF_INCLUDE_DIR NAMES serf.h PATHS "${CURRENT_PACKAGES_DIR}/include/serf" NO_DEFAULT_PATH)
    find_library(SERF_LIBRARY_RELEASE NAMES serf-1 PATHS "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH)
    find_library(SERF_LIBRARY_DEBUG NAMES serf-1 PATHS "${CURRENT_PACKAGES_DIR}/debug/lib" NO_DEFAULT_PATH)

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        SET(INTERFACE_LINK_LIBRARIES "ZLIB::ZLIB;unofficial::apr::apr-1;unofficial::apr::aprapp-1;OpenSSL::SSL;OpenSSL::Crypto")
    else()
        SET(INTERFACE_LINK_LIBRARIES "ZLIB::ZLIB;unofficial::apr::libapr-1;unofficial::apr::libaprapp-1;OpenSSL::SSL;OpenSSL::Crypto")
    endif()

    set_target_properties(unofficial:SERF:serf PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${SERF_INCLUDE_DIR}"
        IMPORTED_LOCATION_RELEASE "${SERF_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${SERF_LIBRARY_DEBUG}"
        IMPORTED_CONFIGURATIONS "Release;Debug"
        INTERFACE_LINK_LIBRARIES "${INTERFACE_LINK_LIBRARIES}"
    )
endif()
