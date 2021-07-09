find_package(CURL CONFIG REQUIRED)

set(LIBCURL_INCLUDE_DIRS ${CURL_INCLUDE_DIRS})
set(LIBCURL_LIBRARIES CURL::libcurl)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBCURL
    REQUIRED_VARS LIBCURL_LIBRARIES LIBCURL_INCLUDE_DIRS
)
