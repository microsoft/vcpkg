include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/libetcd-cpp
    REF cd394bd03affd35d5a7ec5d1535f52d49732143c
    SHA512 d6bcafc05c359ccf523e8d3c468939ba2afc74bc7f34161783a0e7048f178326335c619a5e2ec31d9e6948149053ef6f51b9bc58821b97713d41c9bb27128408
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/etcdpp RENAME copyright)

vcpkg_copy_pdbs()
