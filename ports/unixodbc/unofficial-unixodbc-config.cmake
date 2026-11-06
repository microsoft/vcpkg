if(NOT TARGET unofficial::unixodbc::unixodbc)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        include(CMakeFindDependencyMacro)
        find_dependency(Iconv)
    endif()

    get_filename_component(z_unixodbc_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
    get_filename_component(z_unixodbc_root "${z_unixodbc_root}" PATH)

    find_library(UNIXODBC_LIBRARY_RELEASE NAMES "odbc" PATHS "${z_unixodbc_root}/lib" NO_DEFAULT_PATH REQUIRED)
    add_library(unofficial::unixodbc::unixodbc UNKNOWN IMPORTED)
    set_target_properties(unofficial::unixodbc::unixodbc PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${UNIXODBC_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES "${z_unixodbc_root}/include"
    )
    find_library(UNIXODBC_LIBRARY_DEBUG NAMES "odbc" PATHS "${z_unixodbc_root}/debug/lib" NO_DEFAULT_PATH)
    if(UNIXODBC_LIBRARY_DEBUG)
        set_property(TARGET unofficial::unixodbc::unixodbc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(unofficial::unixodbc::unixodbc PROPERTIES
            IMPORTED_LOCATION_DEBUG "${UNIXODBC_LIBRARY_DEBUG}"
        )
    endif()
    mark_as_advanced(UNIXODBC_LIBRARY_RELEASE UNIXODBC_LIBRARY_DEBUG)

    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        find_library(UNIXODBC_LTDL_LIBRARY_RELEASE NAMES "ltdl" PATHS "${z_unixodbc_root}/lib" NO_DEFAULT_PATH REQUIRED)
        find_library(UNIXODBC_LTDL_LIBRARY_DEBUG NAMES "ltdl" PATHS "${z_unixodbc_root}/debug/lib" NO_DEFAULT_PATH REQUIRED)
        mark_as_advanced(UNIXODBC_LTDL_LIBRARY_RELEASE UNIXODBC_LTDL_LIBRARY_DEBUG)
        if(UNIXODBC_LTDL_LIBRARY_DEBUG)
            set(z_unixodbc_ltdl "$<$<CONFIG:DEBUG>:${UNIXODBC_LTDL_LIBRARY_DEBUG}>;$<$<NOT:$<CONFIG:DEBUG>>:${UNIXODBC_LTDL_LIBRARY_RELEASE}>")
        else()
            set(z_unixodbc_ltdl "${UNIXODBC_LTDL_LIBRARY_RELEASE}")
        endif()
        set_target_properties(unofficial::unixodbc::unixodbc PROPERTIES
            INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:Iconv::Iconv>;${z_unixodbc_ltdl};${CMAKE_DL_LIBS}"
        )
        unset(z_unixodbc_ltdl)
    endif()
    unset(z_unixodbc_root)
endif()

