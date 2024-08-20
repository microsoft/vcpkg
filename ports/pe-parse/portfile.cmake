vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/pe-parse
    REF "v${VERSION}"
    SHA512 fae9060c48e2cebdfbb742c52bc39c36335c1ad4fc7e6bc75a7da012f59d16497630d40ca814c8da71acc44dcce82983ebe13da3a0d389cc53032261fcd1f6bb
    HEAD_REF master
    PATCHES
        arm64-windows-fix.patch
        no-werror.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_COMMAND_LINE_TOOLS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/pe-parse")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
