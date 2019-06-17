include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/libetcd-cpp
    REF 5ac08e4ae365905a4247ddbab8b6fdc8fb7a954a
    SHA512 5ee13dfb36f1cd2df7a7ac30c99f423b8cbad27a7ba002d182033ef83cec1298465a3036aef1f9736049bee500bb22d370e30c9cddd4938d8feb0be00b27448c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE-MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/etcdpp RENAME copyright)

vcpkg_copy_pdbs()
