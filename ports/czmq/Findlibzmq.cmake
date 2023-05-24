find_package(ZeroMQ CONFIG REQUIRED)

set(LIBZMQ_INCLUDE_DIRS ${ZeroMQ_INCLUDE_DIR})
set(LIBZMQ_LIBRARIES libzmq libzmq-static)
set(LIBZMQ_FOUND TRUE)
message(STATUS "Found libzmq: ${LIBZMQ_LIBRARIES}")
