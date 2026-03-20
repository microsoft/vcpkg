cmake_minimum_required(VERSION 3.22)
project(fast-obj C)

add_library(fast-obj fast_obj.c)

target_include_directories(fast-obj PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> 
    $<INSTALL_INTERFACE:include>
)

install(TARGETS fast-obj EXPORT fast-obj-config
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES fast_obj.h DESTINATION include)

install(EXPORT fast-obj-config
    NAMESPACE fast-obj::
    DESTINATION share/fast-obj
)
