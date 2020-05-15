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

target_include_directories(tinyxml 
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:include>
)
install(TARGETS tinyxml
    EXPORT tinyxml-export
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(EXPORT tinyxml-export
FILE
  tinyxmlTargets.cmake
NAMESPACE
   tinyxml::
DESTINATION
    share/tinyxml
)
install(FILES ${HEADERS}
	${CMAKE_CURRENT_BINARY_DIR}/tinyxml_export.h DESTINATION include)
