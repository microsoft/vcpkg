vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VectorCamp/vectorscan
    REF "vectorscan/${VERSION}"
    SHA512 bea79a2b0677f63fa5508089142c28d1536a8d4e618f36c37f36141c07d0fddd2b3ce96ee641cefdc474d185052e29045ef71ba6383526d15fa4b6dc4c940d14
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
