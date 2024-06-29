vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 fd3eb22a055db9567da482182a90d44c79ee8ccb641490945cb45b07686a32a31b7b37aa35b1f3f676a6ede366db01c9cd7b5f7ded899cb1133cdd1aac510154
    HEAD_REF master
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
