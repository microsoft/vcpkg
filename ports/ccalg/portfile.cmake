set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CandyMi/ccalg
    REF "v${VERSION}"
    SHA512 78f7112a81099fcce8f8ac03a4947be1e378c0e744e257a0b310ee6ae4dc3178f047e9f945199aa11b44949f25de08dd228e706e3e3b32d5af8300a9e78ec8e6
    HEAD_REF master
    PATCHES "disable-tests.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_DOCS=OFF
)

vcpkg_cmake_install()

# CMake config for find_package(ccalg REQUIRED CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/ccalg-config.cmake" [[
if(NOT TARGET ccalg::ccalg)
    add_library(ccalg::ccalg INTERFACE IMPORTED)
    set_target_properties(ccalg::ccalg PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
    )
endif()
]])

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/ccalg-config-version.cmake" [[
set(PACKAGE_VERSION 0.1.0)
if("${PACKAGE_FIND_VERSION}" VERSION_EQUAL "${PACKAGE_VERSION}")
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    set(PACKAGE_VERSION_EXACT TRUE)
endif()
]])
