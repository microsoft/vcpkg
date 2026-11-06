vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO neosapience/typecast-sdk
    REF "typecast-c/v${VERSION}"
    SHA512 290fcb33d398286d404bdffeea5c970d9cb8ef34840b98b3db1f98e31fe24eb071553b6ad2e90b8848673adbc1db3880719d1846532b1d8f6fe5181183bb3b5a
    HEAD_REF main
    PATCHES
        use-vcpkg-cjson.patch
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
