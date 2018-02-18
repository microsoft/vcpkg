cmake_minimum_required(VERSION 3.1.2)

project(ebml VERSION 1.3.5)

option(DISABLE_PKGCONFIG "Disable PkgConfig module generation" OFF)
option(DISABLE_CMAKE_CONFIG "Disable CMake package config module generation" OFF)

include(GNUInstallDirs)

set(libebml_SOURCES
  src/Debug.cpp
  src/EbmlBinary.cpp
  src/EbmlContexts.cpp
  src/EbmlCrc32.cpp
  src/EbmlDate.cpp
  src/EbmlDummy.cpp
  src/EbmlElement.cpp
  src/EbmlFloat.cpp
  src/EbmlHead.cpp
  src/EbmlMaster.cpp
  src/EbmlSInteger.cpp
  src/EbmlStream.cpp
  src/EbmlString.cpp
  src/EbmlSubHead.cpp
  src/EbmlUInteger.cpp
  src/EbmlUnicodeString.cpp
  src/EbmlVersion.cpp
  src/EbmlVoid.cpp
  src/IOCallback.cpp
  src/MemIOCallback.cpp
  src/MemReadIOCallback.cpp
  src/SafeReadIOCallback.cpp
  src/StdIOCallback.cpp)

set(libebml_PUBLIC_HEADERS
  ebml/Debug.h
  ebml/EbmlBinary.h
  ebml/EbmlConfig.h
  ebml/EbmlContexts.h
  ebml/EbmlCrc32.h
  ebml/EbmlDate.h
  ebml/EbmlDummy.h
  ebml/EbmlElement.h
  ebml/EbmlEndian.h
  ebml/EbmlFloat.h
  ebml/EbmlHead.h
  ebml/EbmlId.h
  ebml/EbmlMaster.h
  ebml/EbmlSInteger.h
  ebml/EbmlStream.h
  ebml/EbmlString.h
  ebml/EbmlSubHead.h
  ebml/EbmlTypes.h
  ebml/EbmlUInteger.h
  ebml/EbmlUnicodeString.h
  ebml/EbmlVersion.h
  ebml/EbmlVoid.h
  ebml/IOCallback.h
  ebml/MemIOCallback.h
  ebml/MemReadIOCallback.h
  ebml/SafeReadIOCallback.h
  ebml/StdIOCallback.h)
if(WIN32)
  list(APPEND libebml_SOURCES
    src/platform/win32/WinIOCallback.cpp)
  list(APPEND libebml_PUBLIC_HEADERS
    src/platform/win32/WinIOCallback.h)
endif()

set(libebml_C_PUBLIC_HEADERS ebml/c/libebml_t.h)

add_library(ebml ${libebml_SOURCES} ${libebml_PUBLIC_HEADERS} ${libebml_C_PUBLIC_HEADERS})
if(WIN32)
  include(CheckIncludeFile)
  check_include_file(winapifamily.h HAVE_WINAPIFAMILY_H)
  if(HAVE_WINAPIFAMILY_H)
    target_compile_definitions(ebml PUBLIC HAVE_WINAPIFAMILY_H)
  endif()
endif()
set_target_properties(ebml PROPERTIES
  VERSION 4.0.0
  SOVERSION 4)
target_include_directories(ebml PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
if(MSVC)
  target_compile_definitions(ebml PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
if(BUILD_SHARED_LIBS)
  set_target_properties(ebml
	PROPERTIES
		DEFINE_SYMBOL "EBML_DLL_EXPORT"
		C_VISIBILITY_PRESET hidden
		VISIBILITY_INLINES_HIDDEN 1)
  target_compile_definitions(ebml
	PUBLIC EBML_DLL
	PRIVATE EBML_DLL_EXPORT)
endif()

install(TARGETS ebml
  EXPORT EbmlTargets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES ${libebml_PUBLIC_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ebml)
install(FILES ${libebml_C_PUBLIC_HEADERS} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ebml/c)

if(NOT DISABLE_PKGCONFIG)
  set(prefix ${CMAKE_INSTALL_PREFIX})
  set(exec_prefix "\$\{prefix\}")
  set(libdir "\$\{prefix\}/${CMAKE_INSTALL_LIBDIR}")
  set(includedir "\$\{prefix\}/${CMAKE_INSTALL_INCLUDEDIR}")
  set(PACKAGE_VERSION ${PROJECT_VERSION})
  configure_file(libebml.pc.in libebml.pc @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libebml.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
endif()

if(NOT DISABLE_CMAKE_CONFIG)
  if(WIN32)
    set(CMAKE_INSTALL_PACKAGEDIR cmake)
  else()
    set(CMAKE_INSTALL_PACKAGEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
  endif()
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(EbmlConfigVersion.cmake COMPATIBILITY SameMajorVersion)
  install(EXPORT EbmlTargets DESTINATION ${CMAKE_INSTALL_PACKAGEDIR})
  install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/EbmlConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/EbmlConfigVersion.cmake
      DESTINATION ${CMAKE_INSTALL_PACKAGEDIR})
endif()
