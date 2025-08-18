vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc2
    REF "v${VERSION}"
    SHA512 ab9f1846edd7fde710508597e3dfe43f80bb35a20ce913984dfc3c4212c71c009cfc711a330beb6c19858170911c658df463b2b50bd6a1422e656e2bf6e53813
    HEAD_REF main
    PATCHES
        config-typo.patch # https://github.com/Blosc/c-blosc2/pull/690
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLOSC2_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BLOSC2_SHARED)

file(REMOVE_RECURSE "${SOURCE_PATH}/internal-complibs")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        zlib DEACTIVATE_ZLIB
        zstd DEACTIVATE_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPREFER_EXTERNAL_LZ4=ON
        -DPREFER_EXTERNAL_ZLIB=ON
        -DPREFER_EXTERNAL_ZSTD=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB_NG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_LZ4=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZSTD=ON
        -DBUILD_TESTS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC=${BLOSC2_STATIC}
        -DBUILD_SHARED=${BLOSC2_SHARED}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_ZLIB_NG
        CMAKE_REQUIRE_FIND_PACKAGE_ZLIB
        CMAKE_REQUIRE_FIND_PACKAGE_ZSTD
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH "cmake")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Blosc2")
endif()
vcpkg_fixup_pkgconfig()
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Modules") # Find modules that should not be used by vcpkg.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
