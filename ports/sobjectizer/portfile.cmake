vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/sobjectizer
    REF "v.${VERSION}"
    SHA512 f8fe128b4534ad1f7324d6b7f2b290f4c6bb8bfd2acc055b6daa429f14d797aad071630ada3dcc64bc9d337b3f36c88531d162e8caa7fdbff85a27cbcac7dd45
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOBJECTIZER_BUILD_STATIC )
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOBJECTIZER_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev"
    OPTIONS
        -DSOBJECTIZER_BUILD_STATIC=${SOBJECTIZER_BUILD_STATIC}
        -DSOBJECTIZER_BUILD_SHARED=${SOBJECTIZER_BUILD_SHARED}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sobjectizer)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

