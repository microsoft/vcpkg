if (NOT TARGET unofficial::pulsar::pulsar)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)

    find_path(_pulsar_include_dir NAMES "pulsar/Client.h" PATH ${VCPKG_IMPORT_PREFIX})
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}/debug")
    endif ()
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" OR (PULSAR_FORCE_DYNAMIC_LIBRARY AND NOT MSVC))
        find_library(_pulsar_library NAMES libpulsar.so libpulsar.dylib pulsar.lib PATH ${VCPKG_IMPORT_PREFIX})
        set(_pulsar_link_static_library OFF)
        message(STATUS "Found dynamic _pulsar_library: ${_pulsar_library}")
    else ()
        find_library(_pulsar_library NAMES libpulsar.a pulsar-static.lib PATH ${VCPKG_IMPORT_PREFIX})
        set(_pulsar_link_static_library ON)
        message(STATUS "Found static _pulsar_library: ${_pulsar_library}")
    endif ()
    if (NOT _pulsar_include_dir OR NOT _pulsar_library)
        message(FATAL_ERROR "Broken installation of vcpkg port pulsar-client-cpp")
    endif ()

    include(CMakeFindDependencyMacro)
    find_dependency(OpenSSL)
    find_dependency(ZLIB)
    find_dependency(protobuf CONFIG)
    find_dependency(CURL CONFIG)
    find_dependency(zstd CONFIG)
    find_dependency(snappy CONFIG)
    if (MSVC)
        find_dependency(dlfcn-win32 CONFIG)
    endif ()

    add_library(unofficial::pulsar::pulsar INTERFACE IMPORTED)
    set_target_properties(unofficial::pulsar::pulsar PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_pulsar_include_dir}"
        IMPORTED_LOCATION "${_pulsar_library}")
    set(DEPENDENCIES
        ${_pulsar_library}
        OpenSSL::SSL
        OpenSSL::Crypto
        ZLIB::ZLIB
        protobuf::libprotobuf
        CURL::libcurl
        $<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>
        Snappy::snappy
        )
    if (MSVC)
        set(DEPENDENCIES ${DEPENDENCIES} dlfcn-win32::dl)
    endif ()
    if (_pulsar_link_static_library)
        target_compile_definitions(unofficial::pulsar::pulsar INTERFACE PULSAR_STATIC)
    endif ()
    target_link_libraries(unofficial::pulsar::pulsar INTERFACE ${DEPENDENCIES})
    unset(_pulsar_link_static_library)
    unset(_pulsar_library)
    unset(_pulsar_include_dir)
endif ()
