include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ampl/mp
    REF d305155b047b69fc5c6e5fda8630c753d7973b9a
    SHA512 2c8ffd6de946a6f8ea94a8e0c00f03f67753ad99534e0d5fcaaaeb472fe76a3383324bcb628a31d8c01bc5f60254790f5508c8394096a4f05672f814dbd6fe2e
    HEAD_REF master
    PATCHES
    disable-matlab-mex.patch
    workaround-msvc-optimizer-ice.patch
    install-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DBUILD=asl
    -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH share/unofficial-mp
    TARGET_PATH share/unofficial-mp
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share/mp)

configure_file(${SOURCE_PATH}/LICENSE.rst
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs()
vcpkg_test_cmake(PACKAGE_NAME unofficial-mp)
