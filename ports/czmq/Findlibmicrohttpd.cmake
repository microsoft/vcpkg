find_path(LIBMICROHTTPD_INCLUDE_DIRS NAMES microhttpd.h)

get_filename_component(_prefix_path ${LIBMICROHTTPD_INCLUDE_DIRS} PATH)

find_library(
    LIBMICROHTTPD_LIBRARY_DEBUG
    NAMES libmicrohttpd microhttpd
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)

find_library(
    LIBMICROHTTPD_LIBRARY_RELEASE
    NAMES libmicrohttpd microhttpd
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(LIBMICROHTTPD)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBMICROHTTPD
    REQUIRED_VARS LIBMICROHTTPD_LIBRARIES LIBMICROHTTPD_INCLUDE_DIRS
)
