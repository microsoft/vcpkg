if(WIN32)
else(WIN32)
  message(FATAL_ERROR "Findasiosdk.cmake: Unsupported platform ${CMAKE_SYSTEM_NAME}" )
endif(WIN32)

file(READ "${CMAKE_CURRENT_LIST_DIR}/usage" usage)
message(WARNING "find_package(asiosdk) is deprecated.\n${usage}")

# if this script is invoked multiple times, we end up adding
# "asiosdk" to the directory multiple times, leading to incorrect
# include paths
if (ASIOSDK_ROOT_DIR)
    return()
endif()

find_path(
  ASIOSDK_ROOT_DIR
  asiosdk
)

if (NOT "${ASIOSDK_ROOT_DIR}" STREQUAL "")
  set(ASIOSDK_ROOT_DIR
	${ASIOSDK_ROOT_DIR}/asiosdk
  )
endif()

find_path(ASIOSDK_INCLUDE_DIR
  asio.h
  PATHS
  ${ASIOSDK_ROOT_DIR}/common 
)  


if (NOT "${ASIOSDK_ROOT_DIR}" STREQUAL "")
	set (ASIOSDK_INCLUDE_DIR
		${ASIOSDK_ROOT_DIR}/common
		${ASIOSDK_ROOT_DIR}/host
		${ASIOSDK_ROOT_DIR}/host/pc
	)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ASIOSDK DEFAULT_MSG ASIOSDK_ROOT_DIR ASIOSDK_INCLUDE_DIR)

MARK_AS_ADVANCED(
    ASIOSDK_ROOT_DIR ASIOSDK_INCLUDE_DIR
)
