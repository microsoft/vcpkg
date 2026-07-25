vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lidaixingchen/RandX
    REF v${VERSION}
    SHA512 de3207f3a06727dbef82c3cb96e4f1204d965829aaa996560d32eb6c8496c7f77948485333ab01dbb096434ba97dc55842109a7a1173a33c872181a1108fe813
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME RandX CONFIG_PATH lib/cmake/RandX)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
