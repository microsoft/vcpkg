vcpkg_fail_port_install(ON_TARGET "windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/incubator-brpc
    REF 1d6510aa50075cade5ed539ee09a11a1b8d7f990 # 0.9.7
    SHA512 9c9dbe2a202e58586010c56634bd371f6a9e3ff0d8c5341abbabd1f1dd204a3aec5e89061fa326b4fc8ae7202f9fc33f93a5acd845d18dab3915a3e2b81cbaf3
    HEAD_REF master
    PATCHES
        fix_boost_ptr.patch
        fix_thrift.patch
        fix-protobuf-deprecated.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_THRIFT=ON
        -DWITH_MESALINK=OFF
        -DWITH_GLOG=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
