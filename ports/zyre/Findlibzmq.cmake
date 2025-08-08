find_package(ZeroMQ CONFIG REQUIRED)

set(libzmq_INCLUDE_DIRS ${ZeroMQ_INCLUDE_DIR})
set(libzmq_LIBRARIES libzmq libzmq-static)
set(libzmq_FOUND TRUE)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LIBZMQ
    REQUIRED_VARS libzmq_LIBRARIES libzmq_INCLUDE_DIRS libzmq_FOUND
)
