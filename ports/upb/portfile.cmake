vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/upb
    REF  60607da72e89ba0c84c84054d2e562d8b6b61177 # 2020-12-19
    SHA512 d7de03f4a4024136ecccbcd3381058f26ace480f1817cbc1874a8ed4abbbad58dcf61cc77220400004927ab8e8c95ab5a2e1f27172ee3ed3bbd3f1dda2dda07c
    HEAD_REF master
    PATCHES
        add-cmake-install.patch
        fix-uwp.patch
        no-wyhash.patch
        add-all-libs-target.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
