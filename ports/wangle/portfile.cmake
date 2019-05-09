include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/wangle
    REF v2019.05.06.00
    SHA512 59067bf4f349d06458c163b23e8ec71abe868ab7b870792461f3b8ac7d8bb4d0944c7962415ee8c871b430b0a1e1a4577f5710ef6502448a6b52bab7d48d3b91
    HEAD_REF master
    PATCHES
        build.patch
        fix-config-cmake.patch
)
# message(FATAL_ERROR "patch")

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
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/wangle)
