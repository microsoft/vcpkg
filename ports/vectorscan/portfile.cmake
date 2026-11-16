vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VectorCamp/vectorscan
    REF "vectorscan/${VERSION}"
    SHA512 32938f0350c253ea786457747586d054e1a1f0eb45e57013903e69d4e43786ffa1eb04d69e4b98e9df43cfc182705d5f9b10cc123b8483d75aa75f10bcbe2b2b
    HEAD_REF develop
    PATCHES
        remove-Werror.patch
        enable-chimera.patch
        fix-libch-pkgconfig.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        chimera         BUILD_CHIMERA
        dump            DUMP_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TOOLS=OFF
        -DBUILD_UNIT=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_DOC=OFF
        # FAT_RUNTIME is not supported on debug build
        -DFAT_RUNTIME=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
