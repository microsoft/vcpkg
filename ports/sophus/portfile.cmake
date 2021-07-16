vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strasdat/Sophus
    REF v1.0.0
    SHA512 569634a8be9237d2240cf30c01e2677ece75d55f1196030f1228baca62fa22460e8ceb2a63bd46afdf7f02d8eb79c59d6ed666228b852da78590de897b278fab
    HEAD_REF master
    PATCHES
        fix_cmakelists.patch
        disable-werror.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Sophus)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
