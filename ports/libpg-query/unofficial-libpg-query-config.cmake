include(CMakeFindDependencyMacro)
find_dependency(protobuf-c CONFIG REQUIRED)
find_dependency(xxHash CONFIG REQUIRED)

if(NOT TARGET unofficial::libpg-query::libpg-query)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    set(LIBPG_QUERY_PROTO_FILE "${_IMPORT_PREFIX}/share/libpg-query/pg_query.proto"
        CACHE FILEPATH "Path to the libpg-query protobuf schema file")
    add_library(unofficial::libpg-query::libpg-query UNKNOWN IMPORTED)
    set_target_properties(unofficial::libpg-query::libpg-query PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
        INTERFACE_LINK_LIBRARIES "protobuf-c::protobuf-c;xxHash::xxhash"
    )

    find_library(LIBPG_QUERY_LIBRARY_DEBUG NAMES pg_query
        PATHS "${_IMPORT_PREFIX}/debug"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    if(LIBPG_QUERY_LIBRARY_DEBUG)
        set_property(TARGET unofficial::libpg-query::libpg-query APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(unofficial::libpg-query::libpg-query PROPERTIES
            IMPORTED_LOCATION_DEBUG "${LIBPG_QUERY_LIBRARY_DEBUG}"
        )
    endif()

    find_library(LIBPG_QUERY_LIBRARY_RELEASE NAMES pg_query
        PATHS "${_IMPORT_PREFIX}"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    if(LIBPG_QUERY_LIBRARY_RELEASE)
        set_property(TARGET unofficial::libpg-query::libpg-query APPEND PROPERTY IMPORTED_CONFIGURATIONS Release)
        set_target_properties(unofficial::libpg-query::libpg-query PROPERTIES
            IMPORTED_LOCATION_RELEASE "${LIBPG_QUERY_LIBRARY_RELEASE}"
        )
    endif()

    unset(LIBPG_QUERY_LIBRARY_RELEASE)
    unset(LIBPG_QUERY_LIBRARY_DEBUG)
    unset(_IMPORT_PREFIX)
endif()
