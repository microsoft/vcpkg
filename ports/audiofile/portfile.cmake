# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO adamstark/AudioFile
    REF b7dd84abd5763f64fcf74e58499c4b5d779a396d # 1.0.9
    SHA512 daadbf7badadee4a189453af137b1ea5a5ba3486780d02664d1516f379c3705155b1036a9f8f7acd49b6a82269a07e510edcd5e9de55c73f47250244a510ccbb
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