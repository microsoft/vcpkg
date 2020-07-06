vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/chromium/src.git
    REF e4745133a1d3745f066e068b8033c6a269b59caf
    PATCHES
        0001-gtest_prod_util-78.patch
        0002-DEPS-78.patch
        0003-gn-78.patch
        0004-base_build_gn-78.patch
        0005-base_hash_md5-78.patch
        0006-build_config_ios_build_gn-78-ios.patch
        0007-ios_sdk_overrides_gni-78-ios.patch
)

vcpkg_configure_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

vcpkg_install_gn(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS client util third_party/mini_chromium/mini_chromium/base handler:crashpad_handler
)