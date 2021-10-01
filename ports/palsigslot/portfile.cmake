vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO palacaze/sigslot
    REF v1.2.0
    SHA512 6a6fb862a9eeea78732f2191916c7384a4bcb65e42c948f726459ee3cb446f90c4bd18c7c94ee4f9b15c81c5aa729094013805161d532c2284d9e77cdffaa468
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DSIGSLOT_COMPILE_EXAMPLES=OFF
      -DSIGSLOT_COMPILE_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/PalSigslot TARGET_PATH share/PalSigslot)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
