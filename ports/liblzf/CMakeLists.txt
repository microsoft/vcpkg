# Based on http://cvs.schmorp.de/liblzf/Makefile.in?view=markup
cmake_minimum_required(VERSION 3.15)
project(liblzf LANGUAGES C VERSION 3.6)

## Build ##

add_library(liblzf
    lzf_c.c
    lzf_d.c
    liblzf.def
)
set_target_properties(liblzf PROPERTIES OUTPUT_NAME lzf)

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

set(LIBLZF_SHARE_DIR share/liblzf)
install(EXPORT unofficial-liblzf-targets
    FILE unofficial-liblzf-targets.cmake
    NAMESPACE unofficial::liblzf::
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-liblzf-config-version.cmake"
    VERSION ${VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-liblzf-config-version.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-liblzf-targets.cmake"
    DESTINATION ${LIBLZF_SHARE_DIR}
)
