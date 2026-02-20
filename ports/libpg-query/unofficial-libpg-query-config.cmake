include(CMakeFindDependencyMacro)
find_dependency(protobuf-c CONFIG REQUIRED)
find_dependency(xxHash CONFIG REQUIRED)

if(NOT TARGET unofficial::libpg-query::libpg-query)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(unofficial::libpg-query::libpg-query UNKNOWN IMPORTED)
    set_target_properties(unofficial::libpg-query::libpg-query PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )
    find_library(PROTOBUF_C_LIBRARY_RELEASE NAMES protobuf-c
        PATHS "${_IMPORT_PREFIX}"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    find_library(PROTOBUF_C_LIBRARY_DEBUG NAMES protobuf-c
        PATHS "${_IMPORT_PREFIX}/debug"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    if(NOT PROTOBUF_C_LIBRARY_DEBUG)
        set(PROTOBUF_C_LIBRARY_DEBUG "${PROTOBUF_C_LIBRARY_RELEASE}")
    endif()

    find_library(XXHASH_LIBRARY_RELEASE NAMES xxhash
        PATHS "${_IMPORT_PREFIX}"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    find_library(XXHASH_LIBRARY_DEBUG NAMES xxhash
        PATHS "${_IMPORT_PREFIX}/debug"
        PATH_SUFFIXES lib
        NO_DEFAULT_PATH
    )
    if(NOT XXHASH_LIBRARY_DEBUG)
        set(XXHASH_LIBRARY_DEBUG "${XXHASH_LIBRARY_RELEASE}")
    endif()

    set_property(TARGET unofficial::libpg-query::libpg-query APPEND PROPERTY
        INTERFACE_LINK_LIBRARIES
            "$<$<CONFIG:Debug>:${PROTOBUF_C_LIBRARY_DEBUG}>"
            "$<$<NOT:$<CONFIG:Debug>>:${PROTOBUF_C_LIBRARY_RELEASE}>"
            "$<$<CONFIG:Debug>:${XXHASH_LIBRARY_DEBUG}>"
            "$<$<NOT:$<CONFIG:Debug>>:${XXHASH_LIBRARY_RELEASE}>"
    )

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

    unset(LIBPG_QUERY_LIBRARY_RELEASE)
    unset(LIBPG_QUERY_LIBRARY_DEBUG)
    unset(PROTOBUF_C_LIBRARY_RELEASE)
    unset(PROTOBUF_C_LIBRARY_DEBUG)
    unset(XXHASH_LIBRARY_RELEASE)
    unset(XXHASH_LIBRARY_DEBUG)
    unset(_IMPORT_PREFIX)
endif()
