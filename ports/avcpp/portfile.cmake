if(VCPKG_TARGET_IS_WINDOWS)
    # avcpp doesn't export any symbols
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h4tr3d/avcpp
    REF "v${VERSION}"
    SHA512 f23102b3404aad89fe0bf1b7b19c72b09771c55c58043954999afbead7b2e68a4cd807073596c5d39b328fb17c69d23f9e64f86e8092a1b059c05bb6c2df82a7
    HEAD_REF master
    PATCHES
        0002-av_init_packet_deprecation.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AVCPP_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" AVCPP_ENABLE_SHARED)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DAV_ENABLE_STATIC=${AVCPP_ENABLE_STATIC}"
        "-DAV_ENABLE_SHARED=${AVCPP_ENABLE_SHARED}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DAV_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${SOURCE_PATH}/LICENSE.md" LICENSE_MD)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-bsd.txt" "${SOURCE_PATH}/LICENSE-lgpl2.txt" COMMENT "${LICENSE_MD}")
