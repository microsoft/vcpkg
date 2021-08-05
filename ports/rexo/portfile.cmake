vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "christophercrouzet/rexo"
    REF "v0.2.2"
    SHA512 "c7b093920bb23d1b8ecb905c8d3eb281e46607890c071c079df4c194215fc007d672ce3524848a1f0376188869f51fd9955e3fe027c10f3d286a003adfd78d09"
    HEAD_REF "main"
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DREXO_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Rexo)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
configure_file("${SOURCE_PATH}/UNLICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
