vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 d5b1a089f55a19d7c58fac5e1b6471e1835c712eb0ec3c452cc219ed0553fbf64c86a453d32553dc5a7a4b841fd58c3d18563ec4ea9474b1e60f73d8339c5505
    HEAD_REF master
    PATCHES
        add-experimental-library.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        networking   LIBCORO_FEATURE_NETWORKING
        tls          LIBCORO_FEATURE_TLS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBCORO_EXTERNAL_DEPENDENCIES=ON
        -DLIBCORO_BUILD_TESTS=OFF
        -DLIBCORO_BUILD_EXAMPLES=OFF
        -DLIBCORO_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()
