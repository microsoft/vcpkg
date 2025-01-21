vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Soundux/ereignis
    REF "v${VERSION}"
    SHA512 b8c8bbb40bf3501e4612cddfbdbf8117f0e89c7781dfa551f1a62e825566dfd9755889d2c953827679d94198ebfbd8f01e85478d7ac0529b0d564d45788ca707
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
