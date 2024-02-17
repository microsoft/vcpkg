vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF "v${VERSION}"
    SHA512 1af11bea9e75b9b2842197e52d21283fc5ea7ea3ae1034a3e4584e6ca7b364a60589675a0b171d4ff205029730948b91d353f13d11d52c07f1befedc106971b2
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xbyak")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
