cmake_minimum_required(VERSION 3.5)

project(little-cms)

file(GLOB SRCS src/*.c)

add_library(lcms2 ${SRCS} src/lcms2.def)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(lcms2 PRIVATE CMS_DLL_BUILD)
    target_compile_definitions(lcms2 PUBLIC CMS_DLL)
endif()
target_compile_definitions(lcms2 PRIVATE UNICODE _UNICODE)
target_compile_definitions(lcms2 PUBLIC CMS_NO_REGISTER_KEYWORD)

target_include_directories(lcms2 PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)
set_target_properties(lcms2 PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_LIST_DIR}/include/lcms2.h;${CMAKE_CURRENT_LIST_DIR}/include/lcms2_plugin.h")

# Generate pkg-config file
SET(PACKAGE "lcms2")
# Read VERSION from file configure
file(READ "${CMAKE_CURRENT_LIST_DIR}/configure" lcms2_configure)
string(REGEX MATCH "PACKAGE_VERSION='(([0-9]+)\\.([0-9]+))'" _ ${lcms2_configure})
set(VERSION "${CMAKE_MATCH_1}")
SET(prefix "${CMAKE_INSTALL_PREFIX}")
SET(exec_prefix "\${prefix}")
SET(libdir "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
SET(includedir "\${prefix}/include")
CONFIGURE_FILE(lcms2.pc.in "${PROJECT_BINARY_DIR}/lcms2.pc" @ONLY)

install(TARGETS lcms2
    EXPORT lcms2Config
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    PUBLIC_HEADER DESTINATION "include"
)

INSTALL(FILES ${PROJECT_BINARY_DIR}/lcms2.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

install(EXPORT lcms2Config
    DESTINATION "share/lcms2"
    NAMESPACE lcms2::
)

# Backwards compatibility for previous vcpkg users
add_library(lcms INTERFACE)
target_link_libraries(lcms INTERFACE lcms2)


install(TARGETS lcms EXPORT lcms-targets)
install(EXPORT lcms-targets
    DESTINATION "share/lcms"
    NAMESPACE lcms::
)
