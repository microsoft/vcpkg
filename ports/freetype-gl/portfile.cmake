vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rougier/freetype-gl
    REF 85d7850744465ac1dcd00b202787d72a4a3a1f5d
    SHA512 4505b2162610500336ab975a5a0ac2c09503f51b2fb52b433018059f628ef6f6add9618c940a80efebc311d82fe96fa813d356acbd858cc2dbac6a1829ab3031
    HEAD_REF master
    PATCHES
        0001-Link-to-dependencies-also-for-static-build.patch
        0002-Remove-duplicate-installs.patch
        0003-Add-exports.patch
        0004-Change-install-dir-for-pkgconfig.patch
        0005-add-version.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "glad" freetype-gl_WITH_GLAD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dfreetype-gl_BUILD_APIDOC=OFF
        -Dfreetype-gl_BUILD_DEMOS=OFF
        -Dfreetype-gl_BUILD_TESTS=OFF
        -Dfreetype-gl_BUILD_MAKEFONT=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
