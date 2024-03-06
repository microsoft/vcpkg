vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Soundux/lockpp
    REF "v${VERSION}"
    SHA512 540caaec65fc89d1e683af9b7366997b4cd5338ebba9de3ea2003b74dc4b8249a5b1cc223892afddb0e165146c3b36ded26bd88f5fe2c77d125981de8a774baf
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
