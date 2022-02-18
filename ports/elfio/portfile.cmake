vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge1/ELFIO
    REF Release_3.9
    SHA512 479c4132ac3575940bd1e8190ba5253e54ae57f38319d7bca75ea85ee2f744f5d5b460d2d4ceb17eca0d0561c6e281673f050bbdab2f5ff526c031c220876bf1)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
