include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF v2018.12.10.00
    SHA512 158aaef191db5f47040710c3692d23d0ca4dd4010b974dd2b402bbfd1db262feb8053ad4f4c2e11ba005715a3f541a0b2bfdd5e50b3a257c4b879696d6f2c9de
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
        -DINCLUDE_INSTALL_DIR:STRING=include
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/wangle")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/include/wangle/util/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/ssl/test/certs
    ${CURRENT_PACKAGES_DIR}/include/wangle/service/test
    ${CURRENT_PACKAGES_DIR}/include/wangle/deprecated/rx/test
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/wangle RENAME copyright)
