vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeOpcUa/freeopcua
    REF 2f2c886eb2da46b9dc8944c8f79ac31a9f116a81
    SHA512 f19c1489eb116224ac3192e646c08cf3967c9a07064a09c4cbdef89d93e98c7541bb3edd030be22f6daf3f831ff92a324bc3734a8fe34cdd9d5a5ff7cb7f2f19
    HEAD_REF master
    PATCHES
        cmakelists_fixes.patch
        improve_compatibility_with_recent_boost.patch
        use_another_implementation_of_has_begin_end.patch
        uri_facade_win.patch
        serverObj.patch
        include_asio_first.patch
        boost-1.70.patch
        fix-std-headers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DBUILD_PYTHON=OFF
      -DBUILD_TESTING=OFF
      -DSSL_SUPPORT_MBEDTLS=OFF
      -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

#Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/freeopcua RENAME copyright)

vcpkg_fixup_pkgconfig()
