find_path(CZMQ_INCLUDE_DIRS NAMES czmq.h)

find_package(czmq CONFIG REQUIRED)
set(CZMQ_LIBRARIES czmq czmq-static)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    CZMQ
    REQUIRED_VARS CZMQ_INCLUDE_DIRS CZMQ_LIBRARIES
)
