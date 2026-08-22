if(NOT TARGET unofficial::pbc::pbc)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(unofficial::pbc::pbc UNKNOWN IMPORTED)

    set_target_properties(unofficial::pbc::pbc PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )

    find_library(PBC_LIBRARY_DEBUG NAMES pbclib libpbc PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${PBC_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::pbc::pbc APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::pbc::pbc PROPERTIES IMPORTED_LOCATION_DEBUG "${PBC_LIBRARY_DEBUG}")
    endif()

    find_library(PBC_LIBRARY_RELEASE NAMES pbclib libpbc PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${PBC_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::pbc::pbc APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::pbc::pbc PROPERTIES IMPORTED_LOCATION_RELEASE "${PBC_LIBRARY_RELEASE}")
    endif()

    unset(_IMPORT_PREFIX)
endif()
