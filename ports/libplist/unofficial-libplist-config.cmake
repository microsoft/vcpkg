if(NOT TARGET unofficial::libplist::libplist AND NOT TARGET unofficial::libplist::libplist++)
    get_filename_component(Z_LIBPLIST_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." REALPATH)
    find_library(Z_LIBPLIST_LIBRARY_RELEASE NAMES plist-2.0 PATHS "${Z_LIBPLIST_PREFIX}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(Z_LIBPLIST_LIBRARY_DEBUG NAMES plist-2.0 PATHS "${Z_LIBPLIST_PREFIX}/debug/lib" NO_DEFAULT_PATH REQUIRED)
    add_library(unofficial::libplist::libplist UNKNOWN IMPORTED)
    set_target_properties(unofficial::libplist::libplist PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Z_LIBPLIST_PREFIX}/include"
        IMPORTED_CONFIGURATIONS Release
        IMPORTED_LOCATION_RELEASE "${Z_LIBPLIST_LIBRARY_RELEASE}"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE C
    )
    if(Z_LIBPLIST_LIBRARY_DEBUG)
        set_property(TARGET unofficial::libplist::libplist APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(unofficial::libplist::libplist PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_LIBPLIST_LIBRARY_DEBUG}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG C
        )
    endif()
    find_library(Z_LIBPLISTPP_LIBRARY_RELEASE NAMES plist++-2.0 PATHS "${Z_LIBPLIST_PREFIX}/lib" NO_DEFAULT_PATH REQUIRED)
    find_library(Z_LIBPLISTPP_LIBRARY_DEBUG NAMES plist++-2.0 PATHS "${Z_LIBPLIST_PREFIX}/debug/lib" NO_DEFAULT_PATH REQUIRED)
    add_library(unofficial::libplist::libplist++ UNKNOWN IMPORTED)
    set_target_properties(unofficial::libplist::libplist++ PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${Z_LIBPLIST_PREFIX}/include"
        IMPORTED_CONFIGURATIONS Release
        IMPORTED_LOCATION_RELEASE "${Z_LIBPLISTPP_LIBRARY_RELEASE}"
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE CXX
        INTERFACE_LINK_LIBRARIES "$<LINK_ONLY:unofficial::libplist::libplist>"
    )
    if(Z_LIBPLIST_LIBRARY_DEBUG)
        set_property(TARGET unofficial::libplist::libplist++ APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug)
        set_target_properties(unofficial::libplist::libplist++ PROPERTIES
            IMPORTED_LOCATION_DEBUG "${Z_LIBPLISTPP_LIBRARY_DEBUG}"
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG CXX
        )
    endif()
    if(UNIX AND NOT APPLE)
        set_target_properties(unofficial::libplist::libplist PROPERTIES INTERFACE_LINK_LIBRARIES $<LINK_ONLY:m>)
    endif()
endif()
