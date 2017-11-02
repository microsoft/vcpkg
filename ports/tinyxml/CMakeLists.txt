cmake_minimum_required(VERSION 3.4)
project(tinyxml)

set(HEADERS "tinyxml.h")

set(SOURCES "tinyxml.cpp"
            "tinyxmlerror.cpp"
            "tinyxmlparser.cpp"
)

option(BUILD_SHARED_LIBS "Build shared libs" OFF)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(tinyxml ${SOURCES})
target_compile_definitions(tinyxml PRIVATE "-DTIXML_USE_STL")

install(
    TARGETS tinyxml
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES ${HEADERS} DESTINATION include)
