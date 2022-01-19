cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)
cmake_policy(SET CMP0057 NEW)

if(NOT CMAKE_VERSION VERSION_LESS 3.14 AND COMPONENTS IN_LIST ARGS)
    include("${CMAKE_CURRENT_LIST_DIR}/CURLConfigComponents.cmake")
endif()

list(REMOVE_ITEM ARGS "NO_MODULE" "CONFIG" "MODULE")
_find_package(${ARGS} CONFIG)

if(CURL_FOUND)
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
        set(_curl_link_libraries "")
    endif()

    if("Libssh2::libssh2" IN_LIST _curl_link_libraries)
        find_package(Libssh2 CONFIG QUIET)
    endif()

    set(CURL_INCLUDE_DIRS "${_curl_include_dirs}")
    set(CURL_LIBRARY_DEBUG "${_curl_location_debug}")
    set(CURL_LIBRARY_RELEASE "${_curl_location_release}")

    #For builds which rely on CURL_LIBRAR(Y/IES)
    include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
    select_library_configurations(CURL)

    set(CURL_LIBRARIES ${CURL_LIBRARY} ${_curl_link_libraries})
    set(CURL_VERSION_STRING "${CURL_VERSION}")

    unset(_curl_include_dirs)
    unset(_curl_link_libraries)
    unset(_curl_location_debug)
    unset(_curl_location_release)
endif()
cmake_policy(POP)
