_find_package(${ARGS})
if(JPEG_FOUND AND NOT TARGET JPEG::JPEG)
    # Backfill JPEG::JPEG to versions of cmake before 3.12
    add_library(JPEG::JPEG UNKNOWN IMPORTED)
    if(DEFINED JPEG_INCLUDE_DIRS)
        set_target_properties(JPEG::JPEG PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${JPEG_INCLUDE_DIRS}")
    endif()
    if(EXISTS "${JPEG_LIBRARY}")
        set_target_properties(JPEG::JPEG PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES "C"
            IMPORTED_LOCATION "${JPEG_LIBRARY}")
    endif()
    if(EXISTS "${JPEG_LIBRARY_RELEASE}")
        set_property(TARGET JPEG::JPEG APPEND PROPERTY
            IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(JPEG::JPEG PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
            IMPORTED_LOCATION_RELEASE "${JPEG_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${JPEG_LIBRARY_DEBUG}")
        set_property(TARGET JPEG::JPEG APPEND PROPERTY
            IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(JPEG::JPEG PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
            IMPORTED_LOCATION_DEBUG "${JPEG_LIBRARY_DEBUG}")
    endif()
endif()
