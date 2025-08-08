cmake_minimum_required(VERSION 3.30)
project(minc-test C)

find_package(LIBMINC CONFIG REQUIRED)

add_executable(main main.c)
target_include_directories(main PRIVATE ${LIBMINC_INCLUDE_DIRS})
target_link_directories(main PRIVATE ${LIBMINC_LIBRARY_DIRS})
target_link_libraries(main PRIVATE ${LIBMINC_LIBRARIES})

if(NOT EXISTS "${LIBMINC_USE_FILE}")
    message(SEND_ERROR "No such LIBMINC_USE_FILE: ${LIBMINC_USE_FILE}")
endif()
