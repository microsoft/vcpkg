vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO juangburgos/QJsonWebToken
    REF master
    SHA512 20f30d264ca5f761fcba27ddd05ed022bfef47a0e584683750a6eda23e3db12cdb4e8c8f95699e805328a42588e15aff8e5abe4554b4d99eb6c596cfa32b922e
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-qjsonwebtoken CONFIG_PATH share/unofficial-qjsonwebtoken)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
