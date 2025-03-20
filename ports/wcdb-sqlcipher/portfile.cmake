#if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright"
#    OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
#    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
#endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RightFS/sqlcipher
    REF 5f7ef74d1b0134ec505e8341eabcf62170347b68
    HEAD_REF wcdb
    SHA512 ddd883c48a65873f8160518c932ee21e71c8876972aa708e234bb951b4687d5f96b6cd9b2daf565676af0db91dae3d379269780880d89e52008f81026c077e5a
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "sqlcipher")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
