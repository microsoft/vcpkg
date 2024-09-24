#if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright"
#    OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
#    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
#endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RightFS/sqlcipher
    REF 85adde3392c8474dcbb32ce628834886c9a1efcf
    HEAD_REF wcdb
    SHA512 bcfc8a1d1abe2e71384a165ac35236b83edcb8dcbc11da081cc7eabd1a07b46b857b15d5e13ae63b46416aade5efb97689cafce0bf5d8ebd644e989fbb16554e
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "sqlcipher")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
