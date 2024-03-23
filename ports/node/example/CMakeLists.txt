cmake_minimum_required(VERSION 3.25)
project(process-cc_with_libnode LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
enable_testing()

set(sys_root /home/work/opt)
#find_package(node CONFIG REQUIRED)
add_library(libnode INTERFACE)
target_include_directories(libnode INTERFACE ${sys_root}/include/node)
target_link_directories(libnode INTERFACE 
    debug   ${sys_root}/debug/lib
    release  ${sys_root}/lib
)

# target_link_libraries(libnode INTERFACE node)
find_library(LIBNODE_DEBUG NAMES libnode.so.122 PATHS ${sys_root}/debug/lib NO_DEFAULT_PATH)
find_library(LIBNODE_RELEASE NAMES libnode.so.122 PATHS ${sys_root}/lib NO_DEFAULT_PATH)

if(NOT LIBNODE_DEBUG OR NOT LIBNODE_RELEASE)
    message(FATAL_ERROR "libnode not found ${LIBNODE_DEBUG} ${LIBNODE_RELEASE}")
endif()

target_link_libraries(libnode INTERFACE 
    debug ${LIBNODE_DEBUG}
    optimized ${LIBNODE_RELEASE}
)
# target_link_libraries(libnode INTERFACE libnode.so.122)

set(TARGET_NAME process)
add_executable(${TARGET_NAME} process-fixed.cc)
#add_executable(${TARGET_NAME} process.cc)

target_link_libraries(${TARGET_NAME} PRIVATE libnode)

add_test(NAME ${TARGET_NAME} COMMAND ${TARGET_NAME} ${CMAKE_CURRENT_SOURCE_DIR}/count-hosts.js)
