vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF v1.3.7
    SHA512 bfb6f5dbfd49ed38b2b08b3667c06d02e68f649068a050f21a3cc7e1e56b27afd546aaa3199c4f6448f03f6e66a82f9a9dc2241c826d3d1d4acbd38339b9e9fb
    HEAD_REF master
    PATCHES
        0001-Dont-export-vorbisenc-functions.patch
        0002-Fixup-pkgconfig-libs.patch
        0003-def-mingw-compat.patch
        0004-ogg-find-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 # https://github.com/xiph/vorbis/issues/113
    MAYBE_UNUSED_VARIABLES
        CMAKE_POLICY_VERSION_MINIMUM
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME Vorbis CONFIG_PATH "lib/cmake/Vorbis")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
