cmake_minimum_required(VERSION 3.11)

project(Cgl LANGUAGES C CXX)

set(PROJECT_VERSION 0.60.2)
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 60)
set(PROJECT_VERSION_PATCH 2)

set(CMAKE_CXX_STANDARD 14)

set(INSTALL_BIN_DIR      "bin"                      CACHE PATH "Path where exe and dll will be installed")
set(INSTALL_LIB_DIR      "lib"                      CACHE PATH "Path where lib will be installed")
set(INSTALL_INCLUDE_DIR  "include/Coin"             CACHE PATH "Path where headers will be installed")
set(INSTALL_CMAKE_DIR    "share/cgl"                CACHE PATH "Path where cmake configs will be installed")

# Make relative paths absolute (needed later on)
set(RELATIVE_INSTALL_INCLUDE_DIR ${INSTALL_INCLUDE_DIR})
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

find_package(CoinUtils REQUIRED)
find_package(Osi REQUIRED)
find_package(Clp REQUIRED)

file(GLOB CGL_SOURCES
          Cgl/src/CglConfig.h
          Cgl/src/*.hpp
          Cgl/src/*.cpp
          Cgl/src/CglAllDifferent/*.cpp
          Cgl/src/CglAllDifferent/*.hpp
          Cgl/src/CglBKClique/*.cpp
          Cgl/src/CglBKClique/*.hpp
          Cgl/src/CglClique/*.cpp
          Cgl/src/CglClique/*.hpp
          Cgl/src/CglCliqueMerging/*.cpp
          Cgl/src/CglCliqueMerging/*.hpp
          Cgl/src/CglDuplicateRow/*.cpp
          Cgl/src/CglDuplicateRow/*.hpp
          Cgl/src/CglFlowCover/*.cpp
          Cgl/src/CglFlowCover/*.hpp
          Cgl/src/CglGMI/*.cpp
          Cgl/src/CglGMI/*.hpp
          Cgl/src/CglGomory/*.cpp
          Cgl/src/CglGomory/*.hpp
          Cgl/src/CglKnapsackCover/*.cpp
          Cgl/src/CglKnapsackCover/*.hpp
          Cgl/src/CglLandP/*.cpp
          Cgl/src/CglLandP/*.hpp
          Cgl/src/CglLiftAndProject/*.cpp
          Cgl/src/CglLiftAndProject/*.hpp
          Cgl/src/CglMixedIntegerRounding/*.cpp
          Cgl/src/CglMixedIntegerRounding/*.hpp
          Cgl/src/CglMixedIntegerRounding2/*.cpp
          Cgl/src/CglMixedIntegerRounding2/*.hpp
          Cgl/src/CglOddHole/*.cpp
          Cgl/src/CglOddHole/*.hpp
          Cgl/src/CglOddHoleWC/*.cpp
          Cgl/src/CglOddHoleWC/*.hpp
          Cgl/src/CglPreProcess/*.cpp
          Cgl/src/CglPreProcess/*.hpp
          Cgl/src/CglProbing/*.cpp
          Cgl/src/CglProbing/*.hpp
          Cgl/src/CglRedSplit/*.cpp
          Cgl/src/CglRedSplit/*.hpp
          Cgl/src/CglRedSplit2/*.cpp
          Cgl/src/CglRedSplit2/*.hpp
          Cgl/src/CglResidualCapacity/*.cpp
          Cgl/src/CglResidualCapacity/*.hpp
          Cgl/src/CglSimpleRounding/*.cpp
          Cgl/src/CglSimpleRounding/*.hpp
          Cgl/src/CglTwomir/*.cpp
          Cgl/src/CglTwomir/*.hpp
          Cgl/src/CglZeroHalf/*.cpp
          Cgl/src/CglZeroHalf/*.hpp)

add_library(${PROJECT_NAME} ${CGL_SOURCES})

target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           $<INSTALL_INTERFACE:${RELATIVE_INSTALL_INCLUDE_DIR}>
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Cgl/src/>)

target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_CMATH)
target_compile_definitions(${PROJECT_NAME} PUBLIC COIN_HAS_CLP)

target_link_libraries(${PROJECT_NAME} PRIVATE Coin::CoinUtils Coin::Osi Coin::Clp)

install(DIRECTORY Cgl/src/
        DESTINATION ${INSTALL_INCLUDE_DIR}
        FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
        PATTERN "config_default.h" EXCLUDE)

install(TARGETS ${PROJECT_NAME}
        EXPORT "${PROJECT_NAME}Targets"
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin)

include(CMakePackageConfigHelpers)

set(version_config "${CMAKE_CURRENT_BINARY_DIR}/temp/${PROJECT_NAME}ConfigVersion.cmake")
set(project_config "${CMAKE_CURRENT_BINARY_DIR}/temp/${PROJECT_NAME}Config.cmake")
set(namespace "Coin::")

write_basic_package_version_file("${version_config}"
                                 COMPATIBILITY SameMajorVersion)

configure_package_config_file("Config.cmake.in"
                              "${project_config}"
                              INSTALL_DESTINATION
                              "${INSTALL_CMAKE_DIR}")

install(FILES "${project_config}" "${version_config}"
        DESTINATION "${INSTALL_CMAKE_DIR}")

install(EXPORT "${PROJECT_NAME}Targets"
        NAMESPACE "${namespace}"
        DESTINATION "${INSTALL_CMAKE_DIR}")