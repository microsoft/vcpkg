cmake_minimum_required(VERSION 3.4)
project(tinyxml)

set(HEADERS "tinyxml.h")

set(SOURCES "tinyxml.cpp"
            "tinyxmlerror.cpp"
            "tinyxmlparser.cpp"
)

option(BUILD_SHARED_LIBS "Build shared libs" OFF)

add_library(tinyxml ${SOURCES})
target_compile_definitions(tinyxml PRIVATE "-DTIXML_USE_STL")

include(GenerateExportHeader)
generate_export_header(tinyxml)

target_include_directories(tinyxml PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

install(
    TARGETS tinyxml
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES ${HEADERS}
	${CMAKE_CURRENT_BINARY_DIR}/tinyxml_export.h DESTINATION include)
