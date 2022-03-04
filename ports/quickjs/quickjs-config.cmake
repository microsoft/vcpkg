set(TARGET_FILE "${CMAKE_CURRENT_LIST_DIR}/quickjs-targets.cmake")

include(${TARGET_FILE} OPTIONAL RESULT_VARIABLE ret)
if(NOT ret)
    set(${CMAKE_FIND_PACKAGE_NAME}_FOUND FALSE)
    set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "${TARGET_FILE} not found.")
    return()
endif()

# Mark the CMake package as FOUND.
set(${CMAKE_FIND_PACKAGE_NAME}_FOUND TRUE)
