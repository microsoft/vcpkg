find_package(ZeroMQ CONFIG REQUIRED)

set(LIBZMQ_INCLUDE_DIRS ${ZeroMQ_INCLUDE_DIR})
set(LIBZMQ_LIBRARIES libzmq libzmq-static)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBZMQ
    REQUIRED_VARS LIBZMQ_LIBRARIES LIBZMQ_INCLUDE_DIRS
)
