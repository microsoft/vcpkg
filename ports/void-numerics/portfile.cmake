set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/void-numerics
    REF "v${VERSION}"
    SHA512 40140122bdfa3f6ce9f4cc4b659400f3f5f1dc28caf226a9570f445e0d575392931701d4422204f340b476259d4f22e7ce0f63f1728ac36ad29378ddd515c9e6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/void-numerics)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
