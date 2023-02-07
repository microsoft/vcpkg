if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
vcpkg_minimum_required(VERSION 2022-11-10)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v${VERSION}
    SHA512 93aff3549c3d8454c7deded0e64471f2a8290edfd842c2e0816a353ef9ec2896bee25da6d952cc3bbf022262e22ed2a522485dbfe5d1d492f07eb4c0c2ddb779
    HEAD_REF devel
    PATCHES
        fix-install-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCATCH_INSTALL_DOCS=OFF
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
