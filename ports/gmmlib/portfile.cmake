if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 577bb4b8ebe8d6e6dcf17b51bade741c0d523b462dfc188384e06d97f74419a27d3480c21f11f605801cb8b14c2d0d20c9d88e71e7da9af48a95590022081da5
    HEAD_REF master
    PATCHES
        fix-installed-header-includes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRUN_TEST_SUITE=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/GlobalInfo"
    "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Resource"
    "${CURRENT_PACKAGES_DIR}/include/igdgmm/GmmLib/Scripts"
)

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
        "${SOURCE_PATH}/third_party/sse2neon/LICENSE"
        "${SOURCE_PATH}/Source/GmmLib/Utility/GmmLog/spdlog/details/format.h"
        "${SOURCE_PATH}/Source/GmmLib/Utility/GmmLog/spdlog/details/mpmc_bounded_q.h"
)
