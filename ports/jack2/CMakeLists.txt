cmake_minimum_required(VERSION 3.1)
project(jack VERSION 1.9 LANGUAGES C)

include_directories(common)

add_library(jack common/JackWeakAPI.c)
if(WIN32 AND BUILD_SHARED_LIBS)
  target_sources(jack PRIVATE jack.def)
endif()
target_link_libraries(jack PRIVATE ${CMAKE_DL_LIBS})

include(GNUInstallDirs)
install(TARGETS jack
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

set(PREFIX "${CMAKE_INSTALL_PREFIX}")
set(LIBDIR "\${prefix}/${CMAKE_INSTALL_LIBDIR}")
set(INCLUDEDIR "\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
set(JACK_VERSION "${CMAKE_PROJECT_VERSION}")
# JackWeak dynamically loads the real JACK library which requires linking CMAKE_DL_LIBS
if(CMAKE_DL_LIBS)
  set(CLIENTLIB "jack -l${CMAKE_DL_LIBS}")
else()
  set(CLIENTLIB "jack")
endif()
# NOTE: the server_libs variable will be broken but this port does not build the server anyway
configure_file(jack.pc.in "${CMAKE_CURRENT_BINARY_DIR}/jack.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/jack.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

install(DIRECTORY "common/jack" DESTINATION "include")
