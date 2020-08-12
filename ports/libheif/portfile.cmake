vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif 
    REF v1.7.0
    SHA512 7da6ab9daf253c2493e0c3960c6f817e0234dfbd0463467cd1e5f11f7d6804735e401b73fb1038b8f81cfc6527fafb6ac7f4668c3de9400a0131c1292bdbe660 
    HEAD_REF master
    PATCHES
        dont_build_examples_and_gdk_pixbuf.patch
        remove_finding_pkgconfig.patch
        install-extra-headers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libheif/)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
