cmake_minimum_required (VERSION 3.20)

if(NOT DEFINED CPPWINRT_VERSION)
  message(FATAL_ERROR "Requires CPPWINRT_VERSION value")
endif()

project(CppWinRT
  VERSION ${CPPWINRT_VERSION}
  DESCRIPTION "C++/WinRT vcpkg support"
  HOMEPAGE_URL "https://github.com/Microsoft/cppwinrt"
  LANGUAGES CXX)

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CPPWINRT_ARCH win32)
else()
    set(CPPWINRT_ARCH ${VCPKG_TARGET_ARCHITECTURE})
endif()

message(STATUS "Targeting ${CPPWINRT_ARCH}")

include(GNUInstallDirs)

set(CPPWINRT_TOOL "${CMAKE_CURRENT_SOURCE_DIR}/bin/cppwinrt.exe")

set(CPPWINRT_LIB "${CMAKE_CURRENT_SOURCE_DIR}/build/native/lib/${CPPWINRT_ARCH}/cppwinrt_fast_forwarder.lib")

#--- Find Windows SDK Version
if(NOT DEFINED WindowsSDKDir)
    if(EXISTS "$ENV{WindowsSDKDir}" AND (NOT "$ENV{WindowsSDKDir}" STREQUAL ""))
        get_filename_component(WindowsSDKDir "$ENV{WindowsSDKDir}" ABSOLUTE)
    else()
        set(WindowsSDKDir "$ENV{ProgramFiles\(x86\)}/Windows Kits/10")
    endif()
endif()

if (NOT (EXISTS "${WindowsSDKDir}"))
    message(FATAL_ERROR "ERROR: Cannot locate the Windows SDK")
endif()

if (CMAKE_SYSTEM_VERSION MATCHES "^10\\.0\\.[0-9]+\\.0$")
    set(WindowsSDKVersion ${CMAKE_SYSTEM_VERSION})
elseif(CMAKE_SYSTEM_VERSION MATCHES "^10\\.0\\.[0-9]+$")
    set(WindowsSDKVersion "${CMAKE_SYSTEM_VERSION}.0")
endif()

if(NOT DEFINED WindowsSDKVersion)
    if(NOT ("$ENV{WindowsSDKVersion}" STREQUAL ""))
        set(WindowsSDKVersion $ENV{WindowsSDKVersion})
        if (EXISTS "${WindowsSDKDir}/References/${WindowsSDKVersion}")
            message(STATUS "Found Windows SDK and version from environment variables")
            string(REPLACE "\\" ""  WindowsSDKVersion ${WindowsSDKVersion})
        else()
            set(WindowsSDKVersion "")
        endif()
    endif()
endif()

if (NOT (EXISTS "${WindowsSDKDir}/References/${WindowsSDKVersion}/Windows.Foundation.FoundationContract"))
    message(FATAL_ERROR "ERROR: Cannot locate the Windows SDK.")
endif()

message(STATUS "Using .winmd files from ${WindowsSDKVersion} in ${WindowsSDKDir}")

#--- Generate headers
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/winrt/base.h"
    COMMENT "Generating C++/WinRT headers for SDK ${WindowsSDKVersion}"
    COMMAND ${CPPWINRT_TOOL} -in ${WindowsSDKVersion} -out ${CMAKE_CURRENT_BINARY_DIR}
    USES_TERMINAL)

add_library(${PROJECT_NAME} INTERFACE "${CMAKE_CURRENT_BINARY_DIR}/winrt/base.h")

target_include_directories(${PROJECT_NAME} INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Inc>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/cppwinrt>)

#--- Package
include(CMakePackageConfigHelpers)

string(TOLOWER ${PROJECT_NAME} PACKAGE_NAME)

write_basic_package_version_file(
  ${PACKAGE_NAME}-config-version.cmake
  VERSION ${CPPWINRT_VERSION}
  COMPATIBILITY AnyNewerVersion)

install(TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}-targets)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME}/cmake/})

install(EXPORT ${PROJECT_NAME}-targets
  FILE ${PROJECT_NAME}-targets.cmake
  NAMESPACE Microsoft::
  DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME}/cmake/)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/winrt
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PACKAGE_NAME})

install(FILES ${CPPWINRT_LIB}
  DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
  DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME}/cmake/)
