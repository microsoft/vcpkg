include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DuffsDevice/tinyutf8
    REF v2.2
    SHA512 5b524696f2d2b0d09d31498ca03444609f31984007f2c56e4f50cc2eadaa2583de2af07644cf471e08ad88bc1a7881bc34803dbfac18d22e2089792c05ee4b13
    HEAD_REF master
    PATCHES fixbuild.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TINYUTF8_BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DTINYUTF8_BUILD_STATIC=${TINYUTF8_BUILD_STATIC}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENCE ${CURRENT_PACKAGES_DIR}/share/tinyutf8/copyright COPYONLY)

# remove unneeded files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
