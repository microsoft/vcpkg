vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-can/libsocketcan
    REF "v${VERSION}"
    SHA512 88669763ad43ab692ffe49be9335ee2a082dbb8d144e7452d01da66bb59866cd0c19b3c9d1b44c6df21c86d6e30c2b1aa6dd530499a9412bb92887a60023169b
    HEAD_REF master
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CURRENT_PORT_DIR}/libsocketcan-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_build()
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME libsocketcan)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

