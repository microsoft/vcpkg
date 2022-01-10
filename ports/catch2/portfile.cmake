vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v2.13.8
    SHA512 68a45efa47beb3c85d2d7b8a8eba89b8ec1664b4a72bb223227fef1632778aeaf5cf5cc09f40e47aef50426c8661c7d6a69c2dab0b88fbbf7d9a6b2974d6e32e
    HEAD_REF devel
    PATCHES 
        fix-install-path.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCATCH_BUILD_EXAMPLES=OFF
        -DCATCH_BUILD_STATIC_LIBRARY=${BUILD_STATIC}
)

vcpkg_cmake_install()
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/Catch2" "${CURRENT_PACKAGES_DIR}/share/catch2_")
    file(RENAME "${CURRENT_PACKAGES_DIR}/share/catch2_" "${CURRENT_PACKAGES_DIR}/share/catch2")
endif()
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/Catch2" "${CURRENT_PACKAGES_DIR}/debug/share/catch2_")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/catch2_" "${CURRENT_PACKAGES_DIR}/debug/share/catch2")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Catch2")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/catch2/catch.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch.hpp>")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
