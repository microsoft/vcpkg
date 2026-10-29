cmake_minimum_required(VERSION 4.3.3)
project(vcpkg-cpp-module-producer VERSION 1.0.0)

add_library(provider)
target_compile_features(provider PRIVATE cxx_std_20)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(provider
    PRIVATE
      PROVIDER_BUILDING_LIBRARY
    PUBLIC
      PROVIDER_SHARED
  )
endif()

target_sources(provider
  PRIVATE
    src/provider.cpp
  PUBLIC
    FILE_SET CXX_MODULES
    BASE_DIRS
      src
    FILES
      src/provider.cppm
)

include(GNUInstallDirs)

install(
  TARGETS provider
  EXPORT provider-targets
  FILE_SET HEADERS
  FILE_SET CXX_MODULES
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/provider
)

install(
  EXPORT provider-targets
  NAMESPACE provider::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/provider
  FILE providerConfig.cmake
  CXX_MODULES_DIRECTORY cxxmodules
)
