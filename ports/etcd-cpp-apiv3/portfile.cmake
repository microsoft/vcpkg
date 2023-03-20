vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO etcd-cpp-apiv3/etcd-cpp-apiv3
    REF "v${VERSION}"
    SHA512 6c0659e25be84ba85d557d16594a52517b735b593039556bfb3e8b354e13f2f2cce07d82cef4cf793ee24ba39b27d763664de78734feb62059e86db021ca1729
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_ETCD_TESTS=OFF
)
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/etcd-cpp-api)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/etcd-cpp-apiv3" RENAME copyright)

# Adding usage text
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
