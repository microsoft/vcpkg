# Based on http://cvs.schmorp.de/liblzf/Makefile.in?view=markup
cmake_minimum_required(VERSION 3.15)
project(liblzf LANGUAGES C)

## Build ##

add_library(liblzf
    lzf_c.c
    lzf_d.c
    liblzf.def
)
set_target_properties(liblzf PROPERTIES OUTPUT_NAME lzf)
target_include_directories(liblzf INTERFACE $<INSTALL_INTERFACE:include>)
if(MINGW)
    target_compile_definitions(liblzf PRIVATE "_int64=long long")
endif()

## Install ##

include(GNUInstallDirs)
install(TARGETS liblzf
    EXPORT unofficial-liblzf-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(FILES lzf.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

## Write config ##

set(LIBLZF_SHARE_DIR share/unofficial-liblzf)
install(EXPORT unofficial-liblzf-targets
    FILE unofficial-liblzf-config.cmake
    NAMESPACE unofficial::liblzf::
    DESTINATION ${LIBLZF_SHARE_DIR}
)
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-liblzf-config-version.cmake"
    VERSION ${VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-liblzf-config-version.cmake"
    DESTINATION ${LIBLZF_SHARE_DIR}
)
