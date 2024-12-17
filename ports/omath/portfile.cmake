vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO orange-cpp/omath
    REF v1.0.1
    SHA512 467b1abbdf5b9a7f49ed50824eaa4641f05d6088e84f40320b5c82a1bdbf685cc8d0f0a4f4ab6be49e3a8ed13103ee3e808dde3b556a00742f7b53c519c183e3
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/extlibs" "${SOURCE_PATH}/tests")

vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/omathConfig.cmake.in"
    [[# Load the targets for the omath library]]
    "find_dependency(tl-expected)"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/omathConfig.cmake.in"
    [[include("${CMAKE_CURRENT_LIST_DIR}/omathTargets.cmake")]]
    "include(\"${CMAKE_CURRENT_LIST_DIR}/omathTargets.cmake\")\ncheck_required_components(omath)"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/include/omath/projection/Camera.hpp"
    [[#include <expected>]]
    [[#include <tl/expected.hpp>]]
)

vcpkg_replace_string(
    "${SOURCE_PATH}/include/omath/pathfinding/NavigationMesh.hpp"
    [[#include <expected>]]
    [[#include <tl/expected.hpp>]]
)

vcpkg_replace_string(
    "${SOURCE_PATH}/CMakeLists.txt"
    [[# Installation rules]]
    "find_package(tl-expected CONFIG REQUIRED)\ntarget_link_libraries(omath PRIVATE tl::expected)"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/include/omath/pathfinding/NavigationMesh.hpp"
    "std::expected"
    "tl::expected"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/include/omath/projection/Camera.hpp"
    "std::expected"
    "tl::expected"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/source/pathfinding/NavigationMesh.cpp"
    "std::expected"
    "tl::expected"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/include/omath/projection/Camera.hpp"
    "std::unexpected"
    "tl::unexpected"
)

vcpkg_replace_string(
    "${SOURCE_PATH}/source/pathfinding/NavigationMesh.cpp"
    "std::unexpected"
    "tl::unexpected"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOMATH_BUILD_TESTS=OFF
        -DOMATH_THREAT_WARNING_AS_ERROR=OFF
        -DOMATH_BUILD_AS_SHARED_LIBRARY=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
