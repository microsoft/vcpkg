cmake_minimum_required(VERSION 3.8)
project(libxmlmm CXX)

set(CMAKE_SHARED_LIBRARY_PREFIX)
set(CMAKE_STATIC_LIBRARY_PREFIX)

find_package(LibXml2 REQUIRED)

set(HEADERS_LIBXMLMM
	libxmlmm/Attribute.h
	libxmlmm/CData.h
	libxmlmm/Comment.h
	libxmlmm/Content.h
	libxmlmm/defines.h
	libxmlmm/Document.h
	libxmlmm/Element.h
	libxmlmm/exceptions.h
	libxmlmm/libxmlmm.h
	libxmlmm/LibXmlSentry.h
	libxmlmm/Node.h
	libxmlmm/ProcessingInstruction.h
	libxmlmm/Text.h
	libxmlmm/utils.h
)

set(SOURCES_LIBXMLMM
	libxmlmm/Attribute.cpp
	libxmlmm/CData.cpp
	libxmlmm/Comment.cpp
	libxmlmm/Content.cpp
	libxmlmm/Document.cpp
	libxmlmm/Element.cpp
	libxmlmm/LibXmlSentry.cpp
	libxmlmm/Node.cpp
	libxmlmm/ProcessingInstruction.cpp
	libxmlmm/Text.cpp
	libxmlmm/utils.cpp
)

add_library(libxmlmm ${SOURCES_LIBXMLMM})
include_directories(${LIBXML2_INCLUDE_DIR})
target_link_libraries (libxmlmm ${LIBXML2_LIBRARIES})

set_target_properties(libxmlmm PROPERTIES
    CXX_STANDARD 17
    PUBLIC_HEADER "${HEADERS_LIBXMLMM}"
)

target_include_directories(libxmlmm PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/libxmlmm>
    $<INSTALL_INTERFACE:include/libxmlmm>)

install(TARGETS ${PROJECT_NAME}
    EXPORT litehtmlTargets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    PUBLIC_HEADER DESTINATION include/libxmlmm
)
