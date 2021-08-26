vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emil-e/rapidcheck
    REF 7bc7d302191a4f3d0bf005692677126136e02f60
    SHA512 8631f1034a0a24293d61a91cbb8f8b69c70acde02d60377d0a68d045e4d57acb878aafbea76907574c0cc6cdac3a16d207d310b49d7c48ee7edbede3236ed15b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRC_INSTALL_ALL_EXTRAS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
