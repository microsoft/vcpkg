cmake_minimum_required(VERSION 3.20)

set(DVDREAD_VERSION_MAJOR 6)
set(DVDREAD_VERSION_MINOR 1)
set(DVDREAD_VERSION_MICRO 3)
set(DVDREAD_VERSION "${DVDREAD_VERSION_MAJOR}.${DVDREAD_VERSION_MINOR}.${DVDREAD_VERSION_MICRO}")
set(PACKAGE_VERSION ${DVDREAD_VERSION})

project(libdvdread LANGUAGES C VERSION ${DVDREAD_VERSION})

if(MSVC)
    add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
    add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
endif(MSVC)

include(CheckIncludeFile)
include(CheckFunctionExists)

if(WIN32)
check_include_file("${CMAKE_CURRENT_SOURCE_DIR}/msvc/contrib/dirent/dirent.h" HAVE_DIRENT_H)
else(WIN32)
check_include_file(dirent.h HAVE_DIRENT_H)
endif(WIN32)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(limits.h HAVE_LIMITS_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/param.h HAVE_SYS_PARAM_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)

check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)

if(MSVC)
  if (CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    add_definitions(/wd4146)
  endif()
endif()

set(PACKAGE ${PROJECT_NAME})
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_STRING "${PROJECT_NAME} ${DVDREAD_VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NAME})
set(PACKAGE_URL "https://www.videolan.org/developers/libdvdread.html")
set(PACKAGE_VERSION ${DVDREAD_VERSION})
set(STDC_HEADERS 1)
set(SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT 1)
set(SUPPORT_FLAG_VISIBILITY 1)
set(VERSION ${DVDREAD_VERSION})
set(_WIN32_IE "0x0600")
#set(UNUSED "__attribute__((unused))")
set(UNUSED " ")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cm ${CMAKE_BINARY_DIR}/config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/version.h.in ${CMAKE_BINARY_DIR}/version.h @ONLY)

add_library(${PROJECT_NAME}
  src/bitreader.c
  src/bswap.h
  src/dvd_input.c
  src/dvd_input.h
  src/dvd_reader.c
  src/dvd_udf.c
  src/dvdread_internal.h
  src/ifo_print.c
  src/ifo_read.c
  src/md5.c
  src/md5.h
  src/nav_print.c
  src/nav_read.c
  src/logger.c
  src/logger.h
)

find_package(libdvdcss CONFIG REQUIRED)
set(HAVE_DVDCSS_DVDCSS_H 1)

add_library(unofficial::${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

if (WIN32)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/nodefaultlib:vccorlibd /nodefaultlib:msvcrtd vccorlibd.lib msvcrtd.lib")
  else(CMAKE_BUILD_TYPE MATCHES Debug)
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/nodefaultlib:vccorlib /nodefaultlib:msvcrt vccorlib.lib msvcrt.lib")
  endif(CMAKE_BUILD_TYPE MATCHES Debug)
endif(WIN32)

if(WIN32)
target_include_directories(${PROJECT_NAME}
  PRIVATE
  "."
  "src"
  "src/dvdread"
  "msvc/include"
  "msvc/contrib/dirent"
  ${CMAKE_CURRENT_BINARY_DIR}
)
else()
target_include_directories(${PROJECT_NAME}
  PRIVATE
  "."
  "src"
  "src/dvdread"
  ${CMAKE_CURRENT_BINARY_DIR}
)
endif(WIN32)

if(MSVC)
  target_compile_definitions(${PROJECT_NAME}
    PRIVATE
      _CRT_SECURE_NO_WARNINGS
      _CRT_NONSTDC_NO_DEPRECATE
      PATH_MAX=1024
      WIN32_LEAN_AND_MEAN
  )
  set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/DEF:\"${CMAKE_CURRENT_SOURCE_DIR}/msvc/libdvdread.def\"")
  if(CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    set_target_properties(${PROJECT_NAME}
        PROPERTIES
          LINK_FLAGS_DEBUG "/defaultlib:vccorlibd.lib /defaultlib:msvcrtd.lib"
          LINK_FLAGS_RELEASE "/defaultlib:vccorlib.lib /defaultlib:msvcrt.lib"
          LINK_FLAGS_RELWITHDEBINFO "/defaultlib:vccorlib.lib /defaultlib:msvcrt.lib"
    )
  endif()
endif()

target_link_libraries(
        ${PROJECT_NAME}
        PRIVATE
        unofficial::libdvdcss::libdvdcss
)

target_include_directories(${PROJECT_NAME}
    INTERFACE
        $<INSTALL_INTERFACE:include>
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/bitreader.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/dvd_reader.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/dvd_udf.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/ifo_print.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/ifo_read.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/ifo_types.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/nav_print.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/nav_read.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdread/nav_types.h
  ${CMAKE_CURRENT_BINARY_DIR}/version.h
  DESTINATION include/dvdread)

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  INSTALL_DESTINATION "share/${PROJECT_NAME}"
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  DESTINATION "share/${PROJECT_NAME}"
)

install(
    EXPORT ${PROJECT_NAME}-targets
    DESTINATION share/${PROJECT_NAME}
    NAMESPACE unofficial::${PROJECT_NAME}::
)
