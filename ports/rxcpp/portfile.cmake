vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ReactiveX/RxCpp
    REF v4.1.0
    SHA512 a92e817ecbdf6f235cae724ada2615af9fa0c243249625d0f2c2f09ff5dd7f53fdabd03a0278fe2995fe27528c5511d71f87b7a6b3d54f73b49b65aef56e32fd
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
