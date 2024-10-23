vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO berndporr/iir1
    REF "${VERSION}"
    SHA512 2b0658a621cdfb57796cf2fea5411975b442af4af267bce2f613ae53f43572f208fdea59d7ea0178e9984e311c406f289166789aa423505ac8ed2b889ddc9f64
    HEAD_REF master
    PATCHES
        fix-shared-lib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" IIR1_INSTALL_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIIR1_INSTALL_STATIC=${IIR1_INSTALL_STATIC}
        -DIIR1_BUILD_TESTING=OFF
        -DIIR1_BUILD_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME iir CONFIG_PATH lib/cmake/iir)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
