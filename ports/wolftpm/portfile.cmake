vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v${VERSION}
    SHA512 d78203ba0a1d6550f133e4236c254e9f3d6fe4c80a6f35ab978862d2694620e6511bdf36829f136d0d4ed26fd8c77ce89941e35c212ac82c7e84754bb19babb3
    HEAD_REF master
    PATCHES
        fix-cmake-export.patch
    )

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFTPM_EXAMPLES=no
      -DWOLFTPM_FWTPM=no
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
