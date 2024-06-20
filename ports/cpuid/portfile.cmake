vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anrieff/libcpuid
    REF "v${VERSION}"
    SHA512 855dab45ec12b817fb18948442cebc22abaf915a7230e3d1a3f0e2fc7d0e3fe4a39e7c5744be1f4c7e3cb7b082012e6b0b0677a967beba5d404c6c48467eedce
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpuid)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
