vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v3.4.0
    SHA512 03cff1e1ae13525c3c9325b56e0b8d900a4546d94378d1be61125e4873de5114644e3031bdd65178d6c8afb9a4a1c3dff7997bdfbf796266d2420f802d4cd77b
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
