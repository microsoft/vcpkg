list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE")

_find_package(${ARGS} CONFIG)

if(TARGET CURL::libcurl)
    set(CURL_FOUND TRUE)

    get_target_property(_curl_include_dirs CURL::libcurl INTERFACE_INCLUDE_DIRECTORIES)
    get_target_property(_curl_link_libraries CURL::libcurl INTERFACE_LINK_LIBRARIES)

    if (CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        get_target_property(_curl_location_debug CURL::libcurl IMPORTED_IMPLIB_DEBUG)
        get_target_property(_curl_location_release CURL::libcurl IMPORTED_IMPLIB_RELEASE)
    endif()

    if(NOT _curl_location_debug AND NOT _curl_location_release)
        get_target_property(_curl_location_debug CURL::libcurl IMPORTED_LOCATION_DEBUG)
        get_target_property(_curl_location_release CURL::libcurl IMPORTED_LOCATION_RELEASE)
    endif()

    if(NOT _curl_link_libraries)
        set(_curl_link_libraries)
    endif()

    set(CURL_INCLUDE_DIRS "${_curl_include_dirs}")
    set(CURL_LIBRARY_DEBUG "${_curl_location_debug}")
    set(CURL_LIBRARY_RELEASE "${_curl_location_release}")

    #For builds which rely on CURL_LIBRAR(Y/IES)
    include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
    select_library_configurations(CURL)

    set(CURL_LIBRARIES ${CURL_LIBRARY} ${_curl_link_libraries})
    set(CURL_VERSION_STRING "${CURL_VERSION}")

    set(_curl_include_dirs)
    set(_curl_link_libraries)
    set(_curl_location_debug)
    set(_curl_location_release)
endif()
