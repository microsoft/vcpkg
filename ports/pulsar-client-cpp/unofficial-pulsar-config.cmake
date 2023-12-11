if (NOT TARGET unofficial::pulsar::pulsar)
    get_filename_component(VCPKG_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)
    get_filename_component(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}" PATH)

    find_path(_pulsar_include_dir NAMES "pulsar/Client.h" PATH ${VCPKG_IMPORT_PREFIX})
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(VCPKG_IMPORT_PREFIX "${VCPKG_IMPORT_PREFIX}/debug")
    endif ()
    if ("@VCPKG_LIBRARY_LINKAGE" STREQUAL "dynamic" OR PULSAR_FORCE_DYNAMIC_LIBRARY)
        find_library(_pulsar_library NAMES libpulsar.so libpulsar.dylib pulsar.lib PATH ${VCPKG_IMPORT_PREFIX})
    else ()
        find_library(_pulsar_library NAMES libpulsar.a pulsar-static.lib PATH ${VCPKG_IMPORT_PREFIX})
    endif ()
    if (NOT _pulsar_include_dir OR NOT _pulsar_library)
        message(FATAL_ERROR "Broken installation of vcpkg port pulsar-client-cpp")
    endif ()

    find_package(protobuf CONFIG REQUIRED)
    find_package(CURL CONFIG REQUIRED)
    find_package(zstd CONFIG REQUIRED)
    find_package(snappy CONFIG REQUIRED)

    add_library(unofficial::pulsar::pulsar INTERFACE IMPORTED)
    set_target_properties(unofficial::pulsar::pulsar PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_pulsar_include_dir}"
        IMPORTED_LOCATION "${_pulsar_library}")
    target_link_libraries(unofficial::pulsar::pulsar INTERFACE
        ${_pulsar_library}
        protobuf::libprotobuf
        CURL::libcurl
        $<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>
        Snappy::snappy
        )
    unset(_pulsar_library)
    unset(_pulsar_include_dir)
endif ()
