if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Intel gmmlib currently only supports Linux platforms")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/gmmlib
    REF "intel-gmmlib-${VERSION}"
    SHA512 d5fc772b6ef91973f398edf5eb01c98eb318f9847e1ef1ba34aeee029abe69ed0884a1be90df81f034ac2faed4515364caecaa5dd6a4cb32414b89b27bfca8aa
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
