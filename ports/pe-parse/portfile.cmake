vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/pe-parse
    REF v2.1.0
    SHA512 2589e4049b9edb5aa733684405f77a7d0c2a36c44a9473ff286fa387468600453c908770d6c2b9d635553bfb0fb2a547326c0aa2e4db5ca1f824de64ec3f61d0
    HEAD_REF master
    PATCHES
        arm64-windows-fix.patch
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
