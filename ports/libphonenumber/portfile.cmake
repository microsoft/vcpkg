vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF "v${VERSION}"
    SHA512 03bd6a6c4499a7135dbfe30acfd0ede818008a1c9a40068c04c0d3cff5638ea10502e186b625534d9f06cbc69da81c470f7d7308cdd08b41428b1a2e0236f409
    HEAD_REF master
    PATCHES 
        fix-re2-identifiers.patch
        fix-icui18n-lib-name.patch
        fix-find-protobuf.patch
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
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
