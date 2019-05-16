# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pfultz2/Linq
    REF 51e45d25faa95f945d0bf515f214feed4401e542
    SHA512 128973f79f1cc1f63b5ad4501cc3247352559de382c2ab2fc8fb2df90f8926e373db3469414a2e3816f27fb606c1139a25e94b4e5203201e7ab0320b4b004b4d
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/linq TARGET_PATH share/linq)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME linq)
