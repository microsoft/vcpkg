vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libphonenumber
    REF "v${VERSION}"
    SHA512 b864f0ff25ed32813dfa7db5d92ada501566b4d6c366f6ee856dff82680631b88acf24def742015d112e20d4e8aa7c6312c04afb846d492d1f5bef93099775ec
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
