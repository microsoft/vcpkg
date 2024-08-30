find_path(czmq_INCLUDE_DIRS NAMES czmq.h)

find_package(czmq CONFIG REQUIRED)
set(czmq_LIBRARIES czmq czmq-static)
set(libzmq_FOUND TRUE)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CZMQ
    REQUIRED_VARS czmq_INCLUDE_DIRS czmq_LIBRARIES libzmq_FOUND
)
