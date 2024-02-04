# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adamstark/AudioFile
    REF "${VERSION}"
    SHA512 b0612e6d6c440e52a168f27410d6ac14f7fcef2ba183e8a80e03f924e6fc778c01e4f46b40cab10dd73c48f8f10dc4112c58f602728fdeec0bc3e143852fc95e
    HEAD_REF master
    PATCHES
        fix-cmakeLists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME AudioFile)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)