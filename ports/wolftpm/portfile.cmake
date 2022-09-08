vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v2.6.0
    SHA512 1339806859d6fb0e6aef37e6f87be2e49462eccb01d5ca51fdf98bc3b3a1af75f78abe9c8e302b6f9251196e033e639198e980d2500b839403fe6cb10a07743c
    HEAD_REF master
    PATCHES
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
