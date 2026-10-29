if (NOT TARGET unofficial::pulsar::pulsar)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)

    find_path(_pulsar_include_dir NAMES "pulsar/Client.h" PATHS "${VCPKG_IMPORT_PREFIX}/include" NO_DEFAULT_PATH)
    find_library(_pulsar_library_release NAMES pulsar pulsar-static PATHS "${VCPKG_IMPORT_PREFIX}/lib" NO_DEFAULT_PATH)
    find_library(_pulsar_library_debug NAMES pulsar pulsar-static PATHS "${VCPKG_IMPORT_PREFIX}/debug/lib" NO_DEFAULT_PATH)
    message(STATUS "Found _pulsar_library_release: ${_pulsar_library_release}")
    message(STATUS "Found _pulsar_library_debug: ${_pulsar_library_debug}")
    if (NOT _pulsar_include_dir OR NOT _pulsar_library_release)
        message(FATAL_ERROR "Broken installation of vcpkg port pulsar-client-cpp")
    endif ()

    if (MSVC AND "@VCPKG_LIBRARY_LINKAGE@" STREQUAL "dynamic")
        find_file(_pulsar_release_dll NAMES "pulsar.dll" PATHS "${VCPKG_IMPORT_PREFIX}/bin" NO_DEFAULT_PATH)
        find_file(_pulsar_debug_dll NAMES "pulsar.dll" PATHS "${VCPKG_IMPORT_PREFIX}/debug/bin" NO_DEFAULT_PATH)
        if (NOT _pulsar_release_dll)
            message(FATAL_ERROR "No pulsar.dll found")
        endif ()
        message(STATUS "Found _pulsar_release_dll: ${_pulsar_release_dll}")
        message(STATUS "Found _pulsar_debug_dll: ${_pulsar_debug_dll}")
    endif ()

    # When CMAKE_BUILD_TYPE is not specified, debug libraries will be found for dependencies except ZLIB.
    # So set it with Debug here to link debug ZLIB library by default.
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
    endif ()

    include(CMakeFindDependencyMacro)
    find_dependency(OpenSSL)
    find_dependency(ZLIB)
    find_dependency(protobuf CONFIG)
    find_dependency(CURL CONFIG)
    find_dependency(zstd CONFIG)
    find_dependency(Snappy CONFIG)
    if (MSVC)
        find_dependency(dlfcn-win32 CONFIG)
    endif ()

    if (_pulsar_release_dll)
        add_library(unofficial::pulsar::pulsar SHARED IMPORTED)
        set_target_properties(unofficial::pulsar::pulsar PROPERTIES
            IMPORTED_CONFIGURATIONS "RELEASE"
            IMPORTED_IMPLIB_RELEASE "${_pulsar_library_release}"
            IMPORTED_LOCATION_RELEASE "${_pulsar_release_dll}")
        if (_pulsar_debug_dll)
            set_target_properties(unofficial::pulsar::pulsar PROPERTIES
                IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
                IMPORTED_IMPLIB_DEBUG "${_pulsar_library_debug}"
                IMPORTED_LOCATION_DEBUG "${_pulsar_debug_dll}")
            unset(_pulsar_debug_dll CACHE)
        endif ()
        unset(_pulsar_release_dll CACHE)
    else ()
        add_library(unofficial::pulsar::pulsar UNKNOWN IMPORTED)
        set_target_properties(unofficial::pulsar::pulsar PROPERTIES
            IMPORTED_CONFIGURATIONS "RELEASE"
            IMPORTED_LOCATION_RELEASE "${_pulsar_library_release}")
        if (_pulsar_library_debug)
            set_target_properties(unofficial::pulsar::pulsar PROPERTIES
                IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
                IMPORTED_LOCATION_DEBUG "${_pulsar_library_debug}")
            unset(_pulsar_library_debug CACHE)
        endif ()
    endif ()
    set_target_properties(unofficial::pulsar::pulsar PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_pulsar_include_dir}")
    target_link_libraries(unofficial::pulsar::pulsar INTERFACE
        OpenSSL::SSL
        OpenSSL::Crypto
        ZLIB::ZLIB
        protobuf::libprotobuf
        CURL::libcurl
        $<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>
        Snappy::snappy
        )
    if (MSVC)
        target_link_libraries(unofficial::pulsar::pulsar INTERFACE dlfcn-win32::dl)
    endif ()
    unset(_pulsar_library_release CACHE)
    unset(_pulsar_include_dir CACHE)
endif ()
