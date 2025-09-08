if(NOT TARGET lcms2::lcms2)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(lcms2::lcms2 UNKNOWN IMPORTED)

    set_target_properties(lcms2::lcms2 PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )

    find_library(LCMS2_LIBRARY_DEBUG NAMES lcms2 PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_DEBUG}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(lcms2::lcms2 PROPERTIES IMPORTED_LOCATION_DEBUG "${LCMS2_LIBRARY_DEBUG}")
    endif()

    find_library(LCMS2_LIBRARY_RELEASE NAMES lcms2 PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LCMS2_LIBRARY_RELEASE}")
        set_property(TARGET lcms2::lcms2 APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(lcms2::lcms2 PROPERTIES IMPORTED_LOCATION_RELEASE "${LCMS2_LIBRARY_RELEASE}")
    endif()

    unset(_IMPORT_PREFIX)
endif()
