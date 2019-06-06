cmake_minimum_required(VERSION 3.0)

include(GNUInstallDirs)

project(zziplib C)

find_package(zlib)

include_directories(${ZLIB_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if(MSVC)
  set(CMAKE_DEBUG_POSTFIX "d")
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()

if(UNIX)
  # Find autotools output
  set(ZZLIB_AUTOOLS_INCLUDE_DIRS)
  file(GLOB CHILDREN RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/*")
  foreach(CHILD ${CHILDREN})
    string(REGEX MATCH "x86_64*" ZZLIB_AUTOOLS_OUTPUT_FOLDER "${CHILD}")
    if (ZZLIB_AUTOOLS_OUTPUT_FOLDER)
      set(ZZLIB_AUTOOLS_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/${CHILD})
      include_directories(${ZZLIB_AUTOOLS_INCLUDE_DIRS})
      include_directories(${ZZLIB_AUTOOLS_INCLUDE_DIRS}/zzip)
    endif()
  endforeach()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/config.h.in" "${CMAKE_CURRENT_LIST_DIR}/zzip/config.h")
# List the header files
set(HEADERS zzip/__debug.h
            zzip/__dirent.h
            zzip/__fnmatch.h
            zzip/__hints.h
            zzip/__mmap.h
            zzip/config.h
            zzip/_msvc.h
            zzip/autoconf.h
            zzip/conf.h
            zzip/fetch.h
            zzip/file.h
            zzip/format.h
            zzip/fseeko.h
            zzip/info.h
            zzip/lib.h
            zzip/memdisk.h
            zzip/mmapped.h
            zzip/plugin.h
            zzip/stdint.h
            zzip/types.h
            zzip/write.h
            zzip/zzip.h
)
if(UNIX)
  file(GLOB OTHER_HEADERS ${ZZLIB_AUTOOLS_INCLUDE_DIRS}/zzip/*.h)
  list(APPEND HEADERS ${OTHER_HEADERS})
else()
  list(APPEND HEADERS zzip/_msvc.h)
endif()

# List the source files
set(SRCS zzip/dir.c
         zzip/err.c
         zzip/fetch.c
         zzip/file.c
         zzip/info.c
         zzip/plugin.c
         zzip/stat.c
         zzip/zip.c
)

add_library(zziplib ${SRCS} ${HEADERS})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(zziplib PRIVATE -DZZIPLIB_EXPORTS)
endif()

target_link_libraries(zziplib ${ZLIB_LIBRARIES})

install(TARGETS zziplib
        COMPONENT runtime
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT bin
        LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT shlib
        ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT lib)

install(FILES ${HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/zzip)
