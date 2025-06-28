vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 a975c75b7896cefa8ca3e07a81045ddfb29f7ba9fd069d4e8d37430428fe5ce222940c9d58fd549e53be5f92d3d30c7d0c27de1564f49fbc6fb4b866712624ec
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
