cmake_minimum_required(VERSION 3.20)

project(libdvdcss C)

set(DVDCSS_VERSION_MAJOR 1)
set(DVDCSS_VERSION_MINOR 4)
set(DVDCSS_VERSION_MICRO 2)

set(LIBDVDCSS_VERSION "${DVDCSS_VERSION_MAJOR}.${DVDCSS_VERSION_MINOR}.${DVDCSS_VERSION_MICRO}")

include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckFunctionExists)
include(CMakePackageConfigHelpers)

check_include_files("IOKit/storage/IODVDMediaBSDClient.h" DARWIN_DVD_IOCTL)
check_include_files("linux/cdrom.h" DVD_STRUCT_IN_LINUX_CDROM_H)
check_include_files("linux/cdrom.h" HAVE_LINUX_CDROM_H)
check_include_files("sys/cdio.h" DVD_STRUCT_IN_SYS_CDIO_H)
check_include_files("sys/cdio.h" HAVE_SYS_CDIO_H)
check_include_files("sys/dvdio.h" DVD_STRUCT_IN_SYS_DVDIO_H)
check_include_files("sys/dvdio.h" HAVE_SYS_DVDIO_H)
check_include_files("dlfcn.h" HAVE_DLFCN_H)
check_include_files("dvd.h" HAVE_DVD_H)
check_include_files("errno.h" HAVE_ERRNO_H)
check_include_files("fcntl.h" HAVE_FCNTL_H)
check_include_files("inttypes.h" HAVE_INTTYPES_H)
check_include_files("io.h" HAVE_IO_H)
check_include_files("memory.h" HAVE_MEMORY_H)
check_include_files("pwd.h" HAVE_PWD_H)
check_include_files("stdint.h" HAVE_STDINT_H)
check_include_files("stdlib.h" HAVE_STDLIB_H)
check_include_files("strings.h" HAVE_STRINGS_H)
check_include_files("string.h" HAVE_STRING_H)
check_include_files("sys/ioctl.h" HAVE_SYS_IOCTL_H)
check_include_files("sys/param.h" HAVE_SYS_PARAM_H)
check_include_files("sys/scsi/impl/uscsi.h" HAVE_SYS_SCSI_IMPL_USCSI_H)
check_include_files("sys/scsi/scsi_types.h" HAVE_SYS_SCSI_SCSI_TYPES_H)
check_include_files("sys/stat.h" HAVE_SYS_STAT_H)
check_include_files("sys/types.h" HAVE_SYS_TYPES_H)
check_include_files("sys/uio.h" HAVE_SYS_UIO_H)
check_include_files("unistd.h" HAVE_UNISTD_H)
check_include_files("windows.h" HAVE_WINDOWS_H)
check_include_files("winioctl.h" HAVE_WINIOCTL_H)

check_function_exists("mkdir" HAVE_MKDIR_F)
if(NOT HAVE_MKDIR_F OR MSVC)
  set(HAVE_BROKEN_MKDIR 1)
endif()

if(HAVE_SYS_CDIO_H)
  set(BSD_DVD_STRUCT 1)
  set(LINUX_DVD_STRUCT 1)
  set(OPENBSD_DVD_STRUCT 1)
endif()

if(HAVE_SYS_DVDIO_H)
  set(BSD_DVD_STRUCT 1)
  set(LINUX_DVD_STRUCT 1)
endif()

if(HAVE_LINUX_CDROM_H)
  set(LINUX_DVD_STRUCT 1)
endif()

check_type_size(size_t SIZE_T)
if(NOT HAVE_SIZE_T)
  if("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
    set(size_t "uint64_t")
  else("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
    set(size_t   "uint32_t")
  endif("${CMAKE_SIZEOF_VOID_P}" EQUAL 8)
endif(NOT HAVE_SIZE_T)

if(LINUX_DVD_STRUCT)
  set(HAVE_LINUX_DVD_STRUCT 1)
  if(OPENBSD_DVD_STRUCT)
    set(HAVE_OPENBSD_DVD_STRUCT 1)
  endif()
elseif(BSD_DVD_STRUCT)
  set(HAVE_BSD_DVD_STRUCT 1)
endif()

set(PACKAGE ${PROJECT_NAME})
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_STRING "${PROJECT_NAME} ${LIBDVDCSS_VERSION}")
set(PACKAGE_TARNAME ${PROJECT_NAME})
set(PACKAGE_URL "https://www.videolan.org/developers/libdvdcss.html")
set(PACKAGE_VERSION ${LIBDVDCSS_VERSION})
set(STDC_HEADERS 1)
set(SUPPORT_ATTRIBUTE_VISIBILITY_DEFAULT 1)
set(SUPPORT_FLAG_VISIBILITY 1)
set(VERSION ${LIBDVDCSS_VERSION})
set(_WIN32_IE "0x0600")

check_symbol_exists(O_BINARY "fcntl.h" HAVE_O_BINARY)
if(NOT HAVE_O_BINARY)
  set(O_BINARY 1)
endif()

configure_file(${CMAKE_SOURCE_DIR}/config.h.cm ${CMAKE_BINARY_DIR}/config.h)
configure_file(${CMAKE_SOURCE_DIR}/src/dvdcss/version.h.in ${CMAKE_BINARY_DIR}/version.h @ONLY)

add_library(${PROJECT_NAME} 
    src/common.h
    src/css.c
    src/css.h
    src/csstables.h
    src/device.c
    src/device.h
    src/error.c
    src/ioctl.c
    src/ioctl.h
    src/libdvdcss.c
    src/libdvdcss.h
    src/dvdcss/dvdcss.h
)

add_library(unofficial::${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
  PRIVATE
  "."
  "src"
  "src/dvdcss"
  ${CMAKE_CURRENT_BINARY_DIR}
)

if(MSVC)
  target_compile_definitions(${PROJECT_NAME}
    PRIVATE 
      LIBDVDCSS_EXPORTS 
      _CRT_SECURE_NO_WARNINGS
      PATH_MAX=1024
  )
  set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "/DEF:\"${CMAKE_CURRENT_SOURCE_DIR}/msvc/libdvdcss.def\"")
  if(CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    enable_language(CXX)
    target_sources(${PROJECT_NAME} 
      PRIVATE
        ${CMAKE_SOURCE_DIR}/msvc/uwpapi.cpp
    )
    set_source_files_properties(${CMAKE_SOURCE_DIR}/msvc/uwpapi.cpp PROPERTIES COMPILE_FLAGS "/TP /ZW")
    set_target_properties(${PROJECT_NAME}
        PROPERTIES
          LINK_FLAGS_DEBUG "/defaultlib:vccorlibd.lib /defaultlib:msvcrtd.lib"
          LINK_FLAGS_RELEASE "/defaultlib:vccorlib.lib /defaultlib:msvcrt.lib"
          LINK_FLAGS_RELWITHDEBINFO "/defaultlib:vccorlib.lib /defaultlib:msvcrt.lib"
    )
  endif()
endif()

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
  ${CMAKE_CURRENT_LIST_DIR}/src/dvdcss/dvdcss.h
  ${CMAKE_CURRENT_BINARY_DIR}/version.h
  DESTINATION include/dvdcss)

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
