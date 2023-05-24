vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO palacaze/sigslot
    REF v1.2.1
    SHA512 cd79985a09ad41562dc8e582d30bc9df0fdc9409ee3676919b56d0d70a6c1af9414587b61977d2fa2ba763ef8df65b30c7b7dc883629e016660baeb998e708f5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSIGSLOT_COMPILE_EXAMPLES=OFF
      -DSIGSLOT_COMPILE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME PalSigslot CONFIG_PATH lib/cmake/PalSigslot)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
