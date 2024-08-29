cmake_minimum_required(VERSION 3.20)

set(DVDNAV_VERSION_MAJOR 6)
set(DVDNAV_VERSION_MINOR 1)
set(DVDNAV_VERSION_MICRO 1)
set(DVDNAV_VERSION "${DVDNAV_VERSION_MAJOR}.${DVDNAV_VERSION_MINOR}.${DVDNAV_VERSION_MICRO}")
set(PACKAGE_VERSION ${DVDNAV_VERSION})

project(libdvdnav LANGUAGES C VERSION ${DVDNAV_VERSION})

include(CheckIncludeFile)
include(CheckFunctionExists)

check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(limits.h HAVE_LIMITS_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)

check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)

if(MSVC)
  add_definitions(-DWIN32_LEAN_AND_MEAN)
  if (CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    set(_WIN32_IE "0x0A00")
  else()
    set(_WIN32_IE "0x0600")
  endif()
  set(UNUSED " ")
else()
  set(UNUSED "__attribute__((unused))")
endif()

set(PACKAGE "${PROJECT_NAME}")
set(PACKAGE_NAME ${PACKAGE})
set(PACKAGE_STRING "${PACKAGE} ${DVDNAV_VERSION}")
set(PACKAGE_TARNAME ${PACKAGE})
set(PACKAGE_URL "https://www.videolan.org/developers/libdvdnav.html")
set(PACKAGE_VERSION ${DVDNAV_VERSION})
set(STDC_HEADERS 1)
set(SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT 1)
set(SUPPORT_FLAG_VISIBILITY 1)
set(VERSION ${DVDNAV_VERSION})

set(DVDNAV_MAJOR ${DVDNAV_VERSION_MAJOR})
set(DVDNAV_MINOR ${DVDNAV_VERSION_MAJOR})
set(DVDNAV_SUB ${DVDNAV_VERSION_MICRO})

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.cm ${CMAKE_BINARY_DIR}/config.h)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/version.h.in
               ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/version.h @ONLY)

add_library(${PROJECT_NAME}
	src/dvdnav.c
	src/read_cache.c
	src/navigation.c
	src/highlight.c
  src/logger.c
  src/logger.h
	src/searching.c
	src/settings.c
	src/dvdnav_internal.h
	src/read_cache.h
	src/vm/decoder.c
	src/vm/decoder.h
	src/vm/vm.c
	src/vm/vm.h
	src/vm/play.c
	src/vm/play.h
	src/vm/getset.c
	src/vm/getset.h
	src/vm/vmget.c
	src/vm/vmcmd.c
	src/vm/vmcmd.h
)

find_package(libdvdcss CONFIG REQUIRED)
find_package(libdvdread CONFIG REQUIRED)

add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

if(WIN32)
target_include_directories(${PROJECT_NAME}
  PRIVATE
  "."
  "src"
  "src/dvdnav"
  "msvc/include"
  "msvc/contrib/dirent"
  ${CMAKE_CURRENT_BINARY_DIR}
)
else(WIN32)
target_include_directories(${PROJECT_NAME}
  PRIVATE
  "."
  "src"
  "src/dvdnav"
  ${CMAKE_CURRENT_BINARY_DIR}
)
endif(WIN32)

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
      HAVE_CONFIG_H
)

if(MSVC)
  target_compile_definitions(${PROJECT_NAME}
    PRIVATE
      _CRT_SECURE_NO_WARNINGS
      _CRT_NONSTDC_NO_DEPRECATE
      PATH_MAX=1024
      WIN32_LEAN_AND_MEAN
  )
  set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/DEF:\"${CMAKE_CURRENT_SOURCE_DIR}/msvc/libdvdnav.def\"")
  if(CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
     # fix linkage with dvdcss
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
        unofficial::libdvdread::libdvdread
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
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/dvd_types.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/dvdnav.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/dvdnav_events.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dvdnav/version.h
  DESTINATION include/dvdnav)

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
