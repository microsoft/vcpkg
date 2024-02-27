# Based on http://cvs.schmorp.de/liblzf/Makefile.in?view=markup
cmake_minimum_required(VERSION 3.15)
project(liblzf LANGUAGES C VERSION 3.6)

## Build ##

add_library(liblzf
    lzf_c.c
    lzf_d.c
)
set_target_properties(liblzf PROPERTIES OUTPUT_NAME lzf)

# The original autotools config specified -O3 -funroll-all-loops for GCC
if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR
    CMAKE_C_COMPILER_ID STREQUAL "Clang")
  target_compile_options(liblzf PRIVATE "$<$<CONFIG:Release>:-O3>")
  target_compile_options(liblzf PRIVATE "$<$<CONFIG:RelWithDebInfo>:-O3>")
elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  target_compile_options(liblzf PRIVATE "$<$<CONFIG:Release>:/O2>")
  target_compile_options(liblzf PRIVATE "$<$<CONFIG:RelWithDebInfo>:/O2>")
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  target_compile_options(liblzf PRIVATE "-funroll-all-loops")
endif()

set_target_properties(liblzf PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

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
    DESTINATION ${LIBLZF_SHARE_DIR})
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
export(EXPORT unofficial-liblzf-targets
    FILE "${CMAKE_CURRENT_BINARY_DIR}/cmake/unofficial-liblzf-targets.cmake"
    NAMESPACE unofficial::liblzf::)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/cmake/unofficial-liblzf-targets.cmake"
    DESTINATION ${LIBLZF_SHARE_DIR}
)
