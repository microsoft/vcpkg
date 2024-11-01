if(NOT TARGET unofficial::librtpi::librtpi)
    get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
    get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

    add_library(unofficial::librtpi::librtpi UNKNOWN IMPORTED)

    set_target_properties(unofficial::librtpi::librtpi PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
    )

    find_library(LIBRTPI_LIBRARY_DEBUG NAMES rtpi librtpi PATHS "${_IMPORT_PREFIX}/debug" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LIBRTPI_LIBRARY_DEBUG}")
        set_property(TARGET unofficial::librtpi::librtpi APPEND PROPERTY IMPORTED_CONFIGURATIONS "Debug")
        set_target_properties(unofficial::librtpi::librtpi PROPERTIES IMPORTED_LOCATION_DEBUG "${LIBRTPI_LIBRARY_DEBUG}")
    endif()

    find_library(LIBRTPI_LIBRARY_RELEASE NAMES rtpi librtpi PATHS "${_IMPORT_PREFIX}/" PATH_SUFFIXES lib NO_DEFAULT_PATH)
    if(EXISTS "${LIBRTPI_LIBRARY_RELEASE}")
        set_property(TARGET unofficial::librtpi::librtpi APPEND PROPERTY IMPORTED_CONFIGURATIONS "Release")
        set_target_properties(unofficial::librtpi::librtpi PROPERTIES IMPORTED_LOCATION_RELEASE "${LIBRTPI_LIBRARY_RELEASE}")
    endif()

    unset(_IMPORT_PREFIX)
endif()
