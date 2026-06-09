set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/void-numerics
    REF "v${VERSION}"
    SHA512 05a4cd716239dfe2a1ce9bb749f9f9eea8410cfab3f5334a62615be188d0d9ace76b934330ab46d3999f4983b95873f153b917c2731a2d483c36d335552958d5
    HEAD_REF main
    PATCHES
        001-fix-compile-and-link-options.patch
        002-fix-cmake-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/nihilus)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
