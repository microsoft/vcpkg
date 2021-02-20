vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF ec6ff7a71f4a526c39f8ea4e4298f5a2ab3dead7 # v0.162.0
    SHA512 02236badc9b1e3e64dcdeea11ecbc5faa0bfe664e51b97619ad9ceb77124b7f1c496fddb4c002fcdd86d73b3f1587ca01e5fefa39830d74af3d82119c1adbbef
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
