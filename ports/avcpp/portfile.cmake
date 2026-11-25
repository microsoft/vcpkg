if(VCPKG_TARGET_IS_WINDOWS)
    # avcpp doesn't export any symbols
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h4tr3d/avcpp
    REF "v${VERSION}"
    SHA512 9e5eaa9fc6e1b870412d64a21bcf2fbda4fa506812a0e76c3802200d710fcf62de4daa498fbc5b6d46ca3152451fa5fb186617df87fb266f14fd76b16d5fc5ca
    HEAD_REF master
    PATCHES
        0002-av_init_packet_deprecation.patch
        0003-use-ffmpeg-pkgconfig.patch # https://github.com/h4tr3d/avcpp/pull/185
        0004-fix-pkgconfig-libs.patch
        0005-install-filter-headers.patch
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
        -DAVCPP_ENABLE_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST
     "${SOURCE_PATH}/LICENSE.md"
     "${SOURCE_PATH}/LICENSE-bsd.txt"
     "${SOURCE_PATH}/LICENSE-lgpl2.txt"
)
