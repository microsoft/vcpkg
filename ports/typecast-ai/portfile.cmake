vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO neosapience/typecast-sdk
    REF "v${VERSION}"
    SHA512 25fb14a7d46a9873df29571580171d520d9e7115fbbed02428cc228d1652fbe4f8846aec35a043b8bd7540f625dada4486497ca4d51a1c071f5c956c998f76ed
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
