include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF v2018.07.30.00
    SHA512 f83378a8751b47fac2c862e07ffeb2750fd681735e66d778657d7624fe3e839b2e2bfcb049ecd3a3516c206d93f9c168144599ded823720967e44037b536ba5d
    HEAD_REF master
    PATCHES
        build.patch
        gflags.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/wangle"
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/wangle")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/include/wangle/util/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/ssl/test/certs
    ${CURRENT_PACKAGES_DIR}/include/wangle/service/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/deprecated/rx/test
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wangle RENAME copyright)
