cmake_minimum_required(VERSION 3.4)
project(tinyxml)

set(HEADERS "tinyxml.h")

set(SOURCES "tinyxml.cpp"
            "tinyxmlerror.cpp"
            "tinyxmlparser.cpp"
)

option(BUILD_SHARED_LIBS "Build shared libs" OFF)

add_library(unofficial-tinyxml ${SOURCES})
target_compile_definitions(unofficial-tinyxml PRIVATE "-DTIXML_USE_STL")
set_target_properties(unofficial-tinyxml PROPERTIES OUTPUT_NAME tinyxml)

include(GenerateExportHeader)
generate_export_header(unofficial-tinyxml BASE_NAME tinyxml)

target_include_directories(unofficial-tinyxml 
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:include>
)
install(TARGETS unofficial-tinyxml
    EXPORT tinyxml-export
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
install(EXPORT tinyxml-export
FILE
  tinyxmlTargets.cmake
NAMESPACE
  unofficial-tinyxml::
DESTINATION
  share/tinyxml
)
install(FILES ${HEADERS}
	${CMAKE_CURRENT_BINARY_DIR}/tinyxml_export.h DESTINATION include)
