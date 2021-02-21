vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-niel/mfl
    REF v0.0.1
    SHA512 3cf8ab2d6e5058a618f1f91822630d19bdaa7648c4e70e003e5ccf4b26a02a6b5148c35712d83bd8a213eb77576e296e3b6ca66fe58f6c267a9528248f9af4bf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mfl TARGET_PATH share/mfl)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mfl RENAME copyright)
