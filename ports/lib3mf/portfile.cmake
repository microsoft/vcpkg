vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO 3MFConsortium/lib3mf
    REF "v${VERSION}"
    SHA512 acfd0e4862248c475c674f7ee7855f809965a854e62ea0cd847008be7a9ca3c5a03ac87cac889f036555229762405094ca9811817dd45dbdaae941b5b41ae356
    PATCHES
        fix-lib3mf-config-root.patch
        linkage.diff
        pkgconfig.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Libraries")  # vendored

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" _lib3mf_build_shared)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIB3MF_BUILD_SHARED=${_lib3mf_build_shared}
        -DCMAKE_REQUIRE_FIND_PACKAGE_libzip=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DUSE_INCLUDED_ZLIB=OFF
        -DUSE_INCLUDED_LIBZIP=OFF
        -DUSE_INCLUDED_SSL=OFF
        -DUSE_INCLUDED_CPPBASE64=OFF
        -DUSE_INCLUDED_FASTFLOAT=OFF
        -DBUILD_FOR_CODECOVERAGE=OFF
        -DLIB3MF_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lib3mf)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
