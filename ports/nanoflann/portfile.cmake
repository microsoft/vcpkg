vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF e8792e464ab05267216acde8b4ddf301714176a2 #1.3.1
    SHA512 78a04d39b418b6c6582e6d4180958bb0b492547a9662026da07a8b75d7186140bc4d6b50b6eece32db0196607cfcc901aaf4b458e9ab8a9a115b569acc2bae40
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT} TARGET_PATH share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)