vcpkg_download_distfile(patch1679
    URLS "https://patch-diff.githubusercontent.com/raw/apache/incubator-brpc/pull/1679.diff"
    FILENAME "apache-incubator-brpc-1679.diff"
    SHA512 4b1e5717b44aa6a741ddd49b1408e3e556f6d845d5e8a5cfccf2f2d7ebe39aed19c3dad703db7a9ebd0446ac1f225e7dbdd2ff1f23f34fd60c3ef59aaa07b789
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/incubator-brpc
    REF 1d6510aa50075cade5ed539ee09a11a1b8d7f990 # 0.9.7
    SHA512 9c9dbe2a202e58586010c56634bd371f6a9e3ff0d8c5341abbabd1f1dd204a3aec5e89061fa326b4fc8ae7202f9fc33f93a5acd845d18dab3915a3e2b81cbaf3
    HEAD_REF master
    PATCHES
        fix_boost_ptr.patch
        fix_thrift.patch
        ${patch1679}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_THRIFT=ON
        -DWITH_MESALINK=OFF
        -DWITH_GLOG=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
