# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/indicators
    REF 24d92beacafd1348d48eef6d24c6d949b4487a33
    SHA512 7c0b52ec72fce848c16a93dc4d67098158e56b2979554044c588b1c598400e1928442223058ccc92dd4352aca45ea183d72f791899b3fc36e4b388361202b45c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAMPLES=OFF
        -DDEMO=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/indica TARGET_PATH share/indica)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
