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
	set(CURL_INCLUDE_DIRS "${_curl_include_dirs}")
        #for netcdf-c
        set(CURL_LIBRARY CURL::libcurl)
	set(CURL_LIBRARIES CURL::libcurl)
	set(CURL_VERSION_STRING "${CURL_VERSION}")
endif()
