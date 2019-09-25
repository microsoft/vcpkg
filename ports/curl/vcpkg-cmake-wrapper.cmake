set (FOUND_CONFIG FALSE)

foreach (ARG ${ARGS})
    string (TOUPPER "${ARG}" ARG)

    if (${ARG} STREQUAL "CONFIG" OR ${ARG} STREQUAL "NO_MODULE")
        set (FOUND_CONFIG TRUE)
    endif()
endforeach()

if (FOUND_CONFIG)
    _find_package(${ARGS})
else()
    _find_package(${ARGS} CONFIG)
endif()

if(TARGET CURL::libcurl)
    set(CURL_FOUND TRUE)
    get_target_property(_curl_include_dirs CURL::libcurl INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(_curl_location_debug CURL::libcurl IMPORTED_LOCATION_DEBUG)
    get_target_property(_curl_location_release CURL::libcurl IMPORTED_LOCATION_RELEASE)
    get_target_property(_curl_link_libraries CURL::libcurl INTERFACE_LINK_LIBRARIES)

    set(CURL_INCLUDE_DIRS "${_curl_include_dirs}")
    set(CURL_LIBRARY_DEBUG "${_curl_location_debug}")
    set(CURL_LIBRARY_RELEASE "${_curl_location_release}")

    #For libraries which rely on CURL_LIBRAR(Y/IES)
    include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
    select_library_configurations(CURL)

    set(CURL_LIBRARIES "${_curl_link_libraries}" "${CURL_LIBRARY}")
    set(CURL_VERSION_STRING "${CURL_VERSION}")
endif()
