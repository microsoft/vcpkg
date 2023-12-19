if (NOT TARGET unofficial::pulsar::pulsar)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)

    find_path(_pulsar_include_dir NAMES "pulsar/Client.h" PATH "${VCPKG_IMPORT_PREFIX}/include")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}/debug")
    endif ()
    find_library(_pulsar_library NAMES pulsar pulsar-static NAMES NAMES_PER_DIR PATH "${VCPKG_IMPORT_PREFIX}" PATH_SUFFIXES "lib")
    message(STATUS "Found _pulsar_library: ${_pulsar_library}")
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

    add_library(unofficial::pulsar::pulsar UNKNOWN IMPORTED)
    set_target_properties(unofficial::pulsar::pulsar PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_pulsar_include_dir}"
        IMPORTED_LOCATION "${_pulsar_library}")
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
    unset(_pulsar_library CACHE)
    unset(_pulsar_include_dir CACHE)
endif ()
