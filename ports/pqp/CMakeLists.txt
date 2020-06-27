cmake_minimum_required(VERSION 3.0)
project(pqp)

set(SOURCE_CUSTOM_DIR "PQP_v1.3")
include_directories(${SOURCE_CUSTOM_DIR}/src)

file(GLOB SRCS
    "${SOURCE_CUSTOM_DIR}/src/*.cpp")
file(GLOB HDRS
    "${SOURCE_CUSTOM_DIR}/src/*.h")

add_library(pqp STATIC ${SRCS})

install(TARGETS pqp EXPORT pqpConfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

foreach (file ${HDRS})
    get_filename_component(dir ${file} DIRECTORY)
    install(FILES ${file} DESTINATION include/ CONFIGURATIONS Release)
endforeach()
