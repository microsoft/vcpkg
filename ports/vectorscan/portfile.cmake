vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VectorCamp/vectorscan
    REF "vectorscan/${VERSION}"
    SHA512 b9e750cb53a109ebed6e472cccbd280434c4a8e6a9217acfd30c10cc88381712de2444d31794a1f0bebc0b5ca0def21c031234bc1706f4029d51d2830f0cb5ac
    HEAD_REF develop
    PATCHES
        remove-Werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dump            DUMP_SUPPORT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_UNIT=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_DOC=OFF
        # FAT_RUNTIME is not supported on debug build
        -DFAT_RUNTIME=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
