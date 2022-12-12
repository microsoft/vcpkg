vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            abedra/libvault
    REF             0.52.0
    SHA512          f8cc47a65b6b509f5546b3c0911bf5a2946d50d9374d32ea2fa49a3d4aee0766a47d717f1d8736906747381f941bef9ff2f730d46f59ae8ba18af773db2b2ced
    PATCHES
        0001-fix-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TEST=OFF
        -DLINK_CURL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME libvault CONFIG_PATH lib/cmake/libvault)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()


file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
