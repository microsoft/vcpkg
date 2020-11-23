# Try to find NCCL on the local system.
#
# Usage:
# ```cmake
# find_package(NCCL [version] [EXACT] [QUIET] MODULE [REQUIRED])
#
# target_link_libraries(main PRIVATE ${NCCL_LIBRARIES}
# target_include_directories(main PRIVATE ${NCCL_INCLUDE_DIRS})
# ```
#

set(NCCL_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

_find_package(${ARGS})

set(CMAKE_MODULE_PATH ${NCCL_PREV_MODULE_PATH})
