vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 9554fcaf721188e2475933fb8fe6b35f879479af9acb8b011545d66e588a98811f69100a4392e62c3c8bf05e8177760778c44ed4357d40d0a6349833a93fb8e8
    HEAD_REF master
    PATCHES
        0001-allow-shared-lib.patch
        0002-disable-git-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        networking   LIBCORO_FEATURE_NETWORKING
        ssl          LIBCORO_FEATURE_SSL
        threading    LIBCORO_FEATURE_THREADING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBCORO_EXTERNAL_DEPENDENCIES=ON
        -DLIBCORO_BUILD_TESTS=OFF
        -DLIBCORO_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
