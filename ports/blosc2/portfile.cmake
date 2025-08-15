vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc2
    REF "v${VERSION}"
    SHA512 7c40a3b64d956a2141d482bfac65601a999e068262091c51525bde9e05a3667109c5f275688213af0caebbb439cb3004a76f45cb216a468e0793f20e04cc1ba3
    HEAD_REF main
    PATCHES
        configure-binary-dir.patch # https://github.com/Blosc/c-blosc2/pull/679
        cmake-deps.patch # https://github.com/Blosc/c-blosc2/pull/682
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
