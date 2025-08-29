vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v${VERSION}
    SHA512 e6b73ec95f6c0cd37a71063c13db2a95175c54d2c63f69959ed68b4992277f1304136e1ecc5419ce4ff070d9162dbb30a9c6f78c7238383d72c686f1cdc1ab7c
    HEAD_REF master
    PATCHES
      "wolftpm_pr430.diff"
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
