find_path(LIBMICROHTTPD_INCLUDE_DIR NAMES microhttpd.h)

get_filename_component(_prefix_path ${LIBMICROHTTPD_INCLUDE_DIR} PATH)

find_library(
    LIBMICROHTTPD_LIBRARY_DEBUG
    NAMES libmicrohttpd-dll_d libmicrohttpd microhttpd
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)

find_library(
    LIBMICROHTTPD_LIBRARY_RELEASE
    NAMES libmicrohttpd-dll libmicrohttpd microhttpd
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(LIBMICROHTTPD)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBMICROHTTPD
    REQUIRED_VARS LIBMICROHTTPD_LIBRARY LIBMICROHTTPD_INCLUDE_DIR
)

if(LIBMICROHTTPD_FOUND)
    set(LIBMICROHTTPD_INCLUDE_DIRS ${LIBMICROHTTPD_INCLUDE_DIR})
endif()
