vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tiny-utf8
    REF "v${VERSION}"
    SHA512 e87368614671c8e160e9fd7c529bba08f6b3d6bdd0b178c68a4f25a54a6428afe01c3099f80d4976a1b2ce9f2e19b877da54a5dbf024ad25c7a5d5e47cb57bb0
    HEAD_REF master
)

# header-only
set(VCPKG_BUILD_TYPE "release")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYUTF8_BUILD_TESTING=OFF
        -DTINYUTF8_BUILD_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/tinyutf8/cmake)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE")
