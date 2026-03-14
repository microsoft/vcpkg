get_filename_component(z_freetds_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
get_filename_component(z_freetds_root "${z_freetds_root}" PATH)

# Internal static libraries required by ct and db-lib
if(NOT TARGET unofficial::freetds::tds)
    find_library(FREETDS_TDS_LIBRARY_RELEASE NAMES "tds" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(FREETDS_TDS_LIBRARY_DEBUG   NAMES "tds" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)
    find_library(FREETDS_TDSUTILS_LIBRARY_RELEASE NAMES "tdsutils" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(FREETDS_TDSUTILS_LIBRARY_DEBUG   NAMES "tdsutils" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)

    add_library(unofficial::freetds::tds UNKNOWN IMPORTED)
    set_target_properties(unofficial::freetds::tds PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${FREETDS_TDS_LIBRARY_RELEASE}"
    )
    if(FREETDS_TDS_LIBRARY_DEBUG)
        set_property(TARGET unofficial::freetds::tds APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::freetds::tds PROPERTIES IMPORTED_LOCATION_DEBUG "${FREETDS_TDS_LIBRARY_DEBUG}")
    endif()

    add_library(unofficial::freetds::tdsutils UNKNOWN IMPORTED)
    set_target_properties(unofficial::freetds::tdsutils PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${FREETDS_TDSUTILS_LIBRARY_RELEASE}"
    )
    if(FREETDS_TDSUTILS_LIBRARY_DEBUG)
        set_property(TARGET unofficial::freetds::tdsutils APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::freetds::tdsutils PROPERTIES IMPORTED_LOCATION_DEBUG "${FREETDS_TDSUTILS_LIBRARY_DEBUG}")
    endif()

    mark_as_advanced(FREETDS_TDS_LIBRARY_RELEASE FREETDS_TDS_LIBRARY_DEBUG
                     FREETDS_TDSUTILS_LIBRARY_RELEASE FREETDS_TDSUTILS_LIBRARY_DEBUG)
endif()

# DB-Library (sybdb / db-lib)
if(NOT TARGET unofficial::freetds::sybdb)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        find_library(FREETDS_SYBDB_LIBRARY_RELEASE NAMES "db-lib" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(FREETDS_SYBDB_LIBRARY_DEBUG   NAMES "db-lib" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)
    else()
        find_library(FREETDS_SYBDB_LIBRARY_RELEASE NAMES "sybdb" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(FREETDS_SYBDB_LIBRARY_DEBUG   NAMES "sybdb" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)
    endif()

    add_library(unofficial::freetds::sybdb UNKNOWN IMPORTED)
    set_target_properties(unofficial::freetds::sybdb PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${FREETDS_SYBDB_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES "${z_freetds_root}/include"
        INTERFACE_LINK_LIBRARIES "unofficial::freetds::tds;unofficial::freetds::tdsutils"
    )
    if(FREETDS_SYBDB_LIBRARY_DEBUG)
        set_property(TARGET unofficial::freetds::sybdb APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::freetds::sybdb PROPERTIES
            IMPORTED_LOCATION_DEBUG "${FREETDS_SYBDB_LIBRARY_DEBUG}"
        )
    endif()
    mark_as_advanced(FREETDS_SYBDB_LIBRARY_RELEASE FREETDS_SYBDB_LIBRARY_DEBUG)
endif()

# CT-Library (ct)
if(NOT TARGET unofficial::freetds::ct)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        find_library(FREETDS_CT_LIBRARY_RELEASE NAMES "ct" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(FREETDS_CT_LIBRARY_DEBUG   NAMES "ct" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)
    else()
        find_library(FREETDS_CT_LIBRARY_RELEASE NAMES "ct" PATHS "${z_freetds_root}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(FREETDS_CT_LIBRARY_DEBUG   NAMES "ct" PATHS "${z_freetds_root}/debug/lib" NO_DEFAULT_PATH)
    endif()

    add_library(unofficial::freetds::ct UNKNOWN IMPORTED)
    set_target_properties(unofficial::freetds::ct PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${FREETDS_CT_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES "${z_freetds_root}/include"
        INTERFACE_LINK_LIBRARIES "unofficial::freetds::tds;unofficial::freetds::tdsutils"
    )
    if(FREETDS_CT_LIBRARY_DEBUG)
        set_property(TARGET unofficial::freetds::ct APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(unofficial::freetds::ct PROPERTIES
            IMPORTED_LOCATION_DEBUG "${FREETDS_CT_LIBRARY_DEBUG}"
        )
    endif()
    mark_as_advanced(FREETDS_CT_LIBRARY_RELEASE FREETDS_CT_LIBRARY_DEBUG)
endif()

unset(z_freetds_root)
