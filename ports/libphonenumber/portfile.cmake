vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF "v${VERSION}"
    SHA512 849df2433eb264591b8f8040d6b673b415fecd3286ce25f05e545448e34dca8d8f8f5487b428e754dc3272021ae63513827672622124c5b1a0fc6b983aac7c78
    HEAD_REF master
    PATCHES 
        fix-re2-identifiers.patch
        fix-icui18n-lib-name.patch
        fix-find-protobuf.patch
        re2-2023-07-01-compat.patch
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
