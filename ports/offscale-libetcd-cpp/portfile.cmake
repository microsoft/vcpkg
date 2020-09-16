vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/libetcd-cpp
    REF 8607d8d7080c6eb447bc41b799a24bfdb87cf638
    SHA512 9bf4bf14fd52f4f6bbf8cf68de61e6a19eeffbdc501f05c8f614b5f13f206410884afd7fe226a077448e58e02990c65a6b27ee895ed34ba5ee701abe0500b875
    HEAD_REF master
    PATCHES fix-dependency-grpc.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
