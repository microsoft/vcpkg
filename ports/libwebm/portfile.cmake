vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebm
    REF libwebm-${VERSION}
    SHA512 d80ecb37d21586aeff14d0282dfbcde7c71644b6952d3f32f538c6e5eb6cfe835c0eb777d5c633070d796526fbc645b70741c2278c106fb74ed0705123b9a200
    HEAD_REF master
    PATCHES
        Fix-cmake.patch
        fix-export-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${LIBWEBM_CRT_LINKAGE}
        -DENABLE_SAMPLE_PROGRAMS=OFF
        -DENABLE_TESTS=OFF
        -DENABLE_WEBMTS=OFF
        -DENABLE_WEBMINFO=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libwebm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
