vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ReactiveX/RxCpp
    REF v4.1.1
    SHA512 387e1276151a19b62fd1d36b486ff5f3ed28f0f48ae8b00902bf13464d20603f492ecd63ab4444d04293fc3d92a8f7ce3e67a4c68836415c4655331fb6b54edb
    HEAD_REF master
    PATCHES support_find_package.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(COPY ${SOURCE_PATH}/license.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/license.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
