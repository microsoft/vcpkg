vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeOpcUa/freeopcua
    REF 2f2c886eb2da46b9dc8944c8f79ac31a9f116a81
    SHA512 f19c1489eb116224ac3192e646c08cf3967c9a07064a09c4cbdef89d93e98c7541bb3edd030be22f6daf3f831ff92a324bc3734a8fe34cdd9d5a5ff7cb7f2f19
    HEAD_REF master
    PATCHES
        cmakelists_fixes.patch
        use_another_implementation_of_has_begin_end.patch
        serverObj.patch
        fix-std-headers.patch
        uri_facade_win.patch
        boost-compatibility.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DBUILD_PYTHON=OFF
      -DBUILD_TESTING=OFF
      -DSSL_SUPPORT_MBEDTLS=OFF
      -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/freeopcua" RENAME copyright)
vcpkg_fixup_pkgconfig()
