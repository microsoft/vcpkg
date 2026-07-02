if(NOT TARGET lcms2::lcms2)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    # Using SHARED IMPORTED on Windows DLL builds is required so that:
    #   IMPORTED_IMPLIB_*   carries the import library (.lib) used for linking
    #   IMPORTED_LOCATION_* carries the runtime DLL used by TARGET_RUNTIME_DLLS
    # This is required for CMake's TARGET_RUNTIME_DLLS generator expression to
    # propagate the DLL to consumers so it can be copied next to the executable.
    if(WIN32)
        file(GLOB LCMS2_RELEASE_DLLS "${_IMPORT_PREFIX}/bin/*lcms2*.dll")
        if(LCMS2_RELEASE_DLLS)
            add_library(lcms2::lcms2 SHARED IMPORTED)
        else()
            add_library(lcms2::lcms2 UNKNOWN IMPORTED)
        endif()
        unset(LCMS2_RELEASE_DLLS)
    else()
        add_library(lcms2::lcms2 UNKNOWN IMPORTED)
    endif()

    set_target_properties(lcms2::lcms2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
        MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
        MAP_IMPORTED_CONFIG_MINSIZEREL     Release
    )

    find_library(LCMS2_LIBRARY_DEBUG NAMES lcms2 PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_DEBUG}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        file(GLOB LCMS2_DLLS_DEBUG "${_IMPORT_PREFIX}/debug/bin/*lcms2*.dll")
        if(LCMS2_DLLS_DEBUG)
            list(GET LCMS2_DLLS_DEBUG 0 LCMS2_DLL_DEBUG)
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_IMPLIB_DEBUG   "${LCMS2_LIBRARY_DEBUG}"
                IMPORTED_LOCATION_DEBUG "${LCMS2_DLL_DEBUG}"
            )
            unset(LCMS2_DLL_DEBUG)
        else()
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_LOCATION_DEBUG "${LCMS2_LIBRARY_DEBUG}"
            )
        endif()
        unset(LCMS2_DLLS_DEBUG)
    endif()

    find_library(LCMS2_LIBRARY_RELEASE NAMES lcms2 PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_RELEASE}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        file(GLOB LCMS2_DLLS_RELEASE "${_IMPORT_PREFIX}/bin/*lcms2*.dll")
        if(LCMS2_DLLS_RELEASE)
            list(GET LCMS2_DLLS_RELEASE 0 LCMS2_DLL_RELEASE)
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_IMPLIB_RELEASE   "${LCMS2_LIBRARY_RELEASE}"
                IMPORTED_LOCATION_RELEASE "${LCMS2_DLL_RELEASE}"
            )
            unset(LCMS2_DLL_RELEASE)
        else()
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_LOCATION_RELEASE "${LCMS2_LIBRARY_RELEASE}"
            )
        endif()
        unset(LCMS2_DLLS_RELEASE)
    endif()

    unset(_IMPORT_PREFIX)
endif()
