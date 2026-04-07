vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/rtmpdump
    REF 6f6bb1353fc84f4cc37138baa99f586750028a01
    SHA512 e6c108576fdd3430d81e2f72b343864eee5d6be396c9378a2ae2bfc871e9464e20d7bd057a47ef2449a301d933b29265e7ffd3383631b24fc035f5483337bbce
    PATCHES
        fix_strncasecmp.patch
        hide_netstackdump.patch
        pkgconfig.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/librtmp.def" DESTINATION "${SOURCE_PATH}/librtmp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL "${SOURCE_PATH}/librtmp/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/librtmp/librtmp.3.html" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()
