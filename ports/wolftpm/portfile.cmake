vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v3.2.0
    SHA512 8cd63e0b62a2a72838c4ffabe00802d1297989ffbe3fbf20fc523160fc463ab6653ecab4aafb784a3f32d46a5efc71479e29dc1ca2fe1362573deb5b43525773
    HEAD_REF master
    )

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFTPM_EXAMPLES=no
      -DWOLFTPM_BUILD_OUT_OF_TREE=yes
    OPTIONS_DEBUG
      -DCMAKE_C_FLAGS='-DDEBUG_WOLFTPM'
    )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolftpm)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
