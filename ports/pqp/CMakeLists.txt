cmake_minimum_required(VERSION 3.0)
project(pqp)

include_directories(${SOURCE}/src)

file(GLOB SRCS
    "${SOURCE}/src/*.cpp")
file(GLOB HDRS
    "${SOURCE}/src/*.h")

add_library(pqp STATIC ${SRCS})

install(TARGETS pqp EXPORT pqpConfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

foreach (file ${HDRS})
    get_filename_component(dir ${file} DIRECTORY)
    install(FILES ${file} DESTINATION include/ CONFIGURATIONS Release)
endforeach()