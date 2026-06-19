vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO neosapience/typecast-sdk
    REF "v${VERSION}"
    SHA512 9fafc2b2270de52aaec72d6514aa12a7e21119db59b75e684a35f39bafd746d1e09e78d6a25fc9633abbf82e95b62efcaa0a8100aa49e3231c77de31baf12061
    HEAD_REF main
)

# The C SDK is in the typecast-c subdirectory
set(SOURCE_PATH "${SOURCE_PATH}/typecast-c")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTYPECAST_BUILD_SHARED=${BUILD_SHARED}
        -DTYPECAST_BUILD_STATIC=${BUILD_STATIC}
        -DTYPECAST_BUILD_EXAMPLES=OFF
        -DTYPECAST_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/typecast)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
