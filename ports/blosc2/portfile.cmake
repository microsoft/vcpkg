vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Blosc/c-blosc2
    REF "v${VERSION}"
    SHA512 46ef74110fcee712b90543b54116c74dde27604ba17496737ff07c8b236db035e5758ed293cd60b17c10769b0ba19800ca8e6662e4ce325d97eca7433435b7ec
    HEAD_REF main
    PATCHES
        pkgconfig-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BLOSC2_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BLOSC2_SHARED)

file(REMOVE_RECURSE "${SOURCE_PATH}/internal-complibs")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        zlib DEACTIVATE_ZLIB
        zstd DEACTIVATE_ZSTD
)

set(BLOSC2_PC_REQUIRES_PRIVATE "liblz4")
if("zlib" IN_LIST FEATURES)
    string(APPEND BLOSC2_PC_REQUIRES_PRIVATE " zlib")
endif()
if("zstd" IN_LIST FEATURES)
    string(APPEND BLOSC2_PC_REQUIRES_PRIVATE " libzstd")
endif()

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
        -DBLOSC_DEPENDENCY_MODE=EXTERNAL
        "-DBLOSC2_PC_REQUIRES_PRIVATE=${BLOSC2_PC_REQUIRES_PRIVATE}"
        -DBLOSC2_PC_LIBS_PRIVATE=-lzfp
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
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/LICENSES/FASTLZ.txt"
        "${SOURCE_PATH}/LICENSES/BITSHUFFLE.txt"
        "${SOURCE_PATH}/plugins/codecs/ndlz/xxhash.c"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/Modules") # Find modules that should not be used by vcpkg.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
