if(NOT TARGET UNIX::odbc)
    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        include(CMakeFindDependencyMacro)
        find_dependency(Iconv)
    endif()

    get_filename_component(z_unixodbc_root "${CMAKE_CURRENT_LIST_DIR}" PATH)
    get_filename_component(z_unixodbc_root "${z_unixodbc_root}" PATH)

    find_library(UNIXODBC_LIBRARY_RELEASE NAMES "odbc" PATHS "${z_unixodbc_root}/lib" NO_DEFAULT_PATH REQUIRED)
    add_library(UNIX::odbc UNKNOWN IMPORTED)
    set_target_properties(UNIX::odbc PROPERTIES
        IMPORTED_CONFIGURATIONS RELEASE
        IMPORTED_LOCATION_RELEASE "${UNIXODBC_LIBRARY_RELEASE}"
        INTERFACE_INCLUDE_DIRECTORIES "${z_unixodbc_root}/include"
    )
    find_library(UNIXODBC_LIBRARY_DEBUG NAMES "odbc" PATHS "${z_unixodbc_root}/debug/lib" NO_DEFAULT_PATH)
    if(UNIXODBC_LIBRARY_DEBUG)
        set_property(TARGET UNIX::odbc APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG
        )
        set_target_properties(UNIX::odbc PROPERTIES
            IMPORTED_LOCATION_DEBUG "${UNIXODBC_LIBRARY_DEBUG}"
        )
    endif()

    if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
        set_target_properties(UNIX::odbc PROPERTIES
            INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:Iconv::Iconv>;$<LINK_ONLY:ltdl>;${CMAKE_DL_LIBS}"
        )
    endif()
    unset(z_unixodbc_root)
endif()

