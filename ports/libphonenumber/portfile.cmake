vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF "v${VERSION}"
    SHA512 7a21d59a737ff0e5d33a2364933575fa37438b6d74ec75dc734fd8795a81bcde82f0ed58b6a426715a20a2592708844c3ea0204e31931b32a5ee52c1d04f163b
    HEAD_REF master
    PATCHES
        # fix compilation error due to deprecated warnings in protobuf generated files
        disable-werror.patch
        fix-re2-identifiers.patch
        fix-icui18n-lib-name.patch
        fix-find-protobuf.patch
        re2-2023-07-01-compat.patch
        # enable C++17 for re2
        enable-cpp17.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DREGENERATE_METADATA=OFF
        -DUSE_RE2=ON
        -DBUILD_GEOCODER=OFF
        -DUSE_PROTOBUF_LITE=ON
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
