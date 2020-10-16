vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/CAPI
    REF 1.8
    SHA512 6a5f4cb3d36b419f3cd195028c3e6dc17abf3cdb7495aa3df638bc1f842ba98243c73e051e9cfcd3afe22787309cb871374b152ded92e6e06f404cd7b1ae50bf
    HEAD_REF master
    PATCHES
        fix-docs-version.patch
        preserve-install-dir.patch
        remove-tests.patch
        fix-min.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPDALC_ENABLE_CODE_COVERAGE:BOOL=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove headers from debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Install copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
