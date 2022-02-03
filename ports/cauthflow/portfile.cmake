vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             5d785fd8a4a47f37d13e9f65f3d3de569ed74aa4
    SHA512          339b6b3ecdc65ba7c15899e8caae3ebae61ae031dfe2e3eb8ff8cae6c091f76cd8f9e56cf64048a85089d4a37c42ee70cb6461430af294a8447646b120a4d655
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
