# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adamstark/AudioFile
    REF 004065d01e9b7338580390d4fdbfbaa46adede4e # 1.1.0
    SHA512 99d31035fc82ca8da3c555c30b6b40ea99e15e1f82002c7f04c567ab7aee1de71deddf6930564c56f3a2e83eea1b5f5e9ca631673ed4a943579732b8d62e9603
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