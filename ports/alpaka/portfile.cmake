vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alpaka-group/alpaka
    REF ${VERSION}
    SHA512 ee5354c498c9be12f4885d08c1ab9c11e67e3c305ea90c82605e061bd1a3b4efcc1ae17fb92d0cc9c2b402e8ba44431149409d4df903a2c355c382ae07ec9bcd
    HEAD_REF develop
)
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}")
    
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/alpaka")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
