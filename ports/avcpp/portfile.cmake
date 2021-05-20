# avcpp doesn't export any symbols
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO h4tr3d/avcpp
    REF d1a39cf6e1ccfe78ababe5a65d02d57f1e65bea1
    SHA512 48eb3bdd8729c9f61c53b152f0bb7283b40d2c8f043a1d6bb4fb1fadb0ceebf754822eeb7fa85edcacbca267eea0999dd9e78e378b04984db6dc25f9a6fab7d0
    HEAD_REF master
    PATCHES
        0001-remove-problematic-compound-literal.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" AVCPP_ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" AVCPP_ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DAV_ENABLE_STATIC=${AVCPP_ENABLE_STATIC}
        -DAV_ENABLE_SHARED=${AVCPP_ENABLE_SHARED}
        -DAV_BUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()