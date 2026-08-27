if(NOT TARGET lcms2::lcms2)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    function(lcms2_find_runtime_dll _out_var _bin_dir)
        file(GLOB _candidates "${_bin_dir}/*lcms2*.dll")
        foreach(_candidate IN LISTS _candidates)
            get_filename_component(_name "${_candidate}" NAME)
            if(_name MATCHES "^(lib)?lcms2-[0-9]+\.dll")
                set(${_out_var} "${_candidate}" PARENT_SCOPE)
                return()
            endif()
        endforeach()
        set(${_out_var} "" PARENT_SCOPE)
    endfunction()

    # Using SHARED IMPORTED on Windows DLL builds is required so that:
    #   IMPORTED_IMPLIB_*   carries the import library (.lib) used for linking
    #   IMPORTED_LOCATION_* carries the runtime DLL used by TARGET_RUNTIME_DLLS
    if(WIN32)
        lcms2_find_runtime_dll(LCMS2_RELEASE_DLL "${_IMPORT_PREFIX}/bin")
        if(LCMS2_RELEASE_DLL)
            add_library(lcms2::lcms2 SHARED IMPORTED)
        else()
            add_library(lcms2::lcms2 UNKNOWN IMPORTED)
        endif()
        unset(LCMS2_RELEASE_DLL)
    else()
        add_library(lcms2::lcms2 UNKNOWN IMPORTED)
    endif()

    set_target_properties(lcms2::lcms2 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )

    find_library(LCMS2_LIBRARY_DEBUG NAMES lcms2 PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_DEBUG}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        lcms2_find_runtime_dll(LCMS2_DLL_DEBUG "${_IMPORT_PREFIX}/debug/bin")
        if(LCMS2_DLL_DEBUG)
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_IMPLIB_DEBUG   "${LCMS2_LIBRARY_DEBUG}"
                IMPORTED_LOCATION_DEBUG "${LCMS2_DLL_DEBUG}"
            )
        else()
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_LOCATION_DEBUG "${LCMS2_LIBRARY_DEBUG}"
            )
        endif()
        unset(LCMS2_DLL_DEBUG)
    endif()

    find_library(LCMS2_LIBRARY_RELEASE NAMES lcms2 PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_RELEASE}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        lcms2_find_runtime_dll(LCMS2_DLL_RELEASE "${_IMPORT_PREFIX}/bin")
        if(LCMS2_DLL_RELEASE)
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_IMPLIB_RELEASE   "${LCMS2_LIBRARY_RELEASE}"
                IMPORTED_LOCATION_RELEASE "${LCMS2_DLL_RELEASE}"
            )
        else()
            set_target_properties(lcms2::lcms2 PROPERTIES
                IMPORTED_LOCATION_RELEASE "${LCMS2_LIBRARY_RELEASE}"
            )
        endif()
        unset(LCMS2_DLL_RELEASE)
    endif()

    unset(_IMPORT_PREFIX)
endif()
