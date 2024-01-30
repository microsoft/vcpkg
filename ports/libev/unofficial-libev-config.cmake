if(NOT TARGET unofficial::libev::libev)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(unofficial::libev::libev UNKNOWN IMPORTED)

    set_target_properties(unofficial::libev::libev PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )

    find_library(LIBEV_LIBRARY_DEBUG NAMES ev libev PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LIBEV_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::libev::libev APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::libev::libev PROPERTIES IMPORTED_LOCATION_DEBUG "${LIBEV_LIBRARY_DEBUG}")
    endif()

    find_library(LIBEV_LIBRARY_RELEASE NAMES ev libev PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LIBEV_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::libev::libev APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::libev::libev PROPERTIES IMPORTED_LOCATION_RELEASE "${LIBEV_LIBRARY_RELEASE}")
    endif()

    unset(_IMPORT_PREFIX)
endif()
