string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" VERSION_STR "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO herumi/xbyak
    REF "v${VERSION_STR}"
    SHA512 42b8338a1bf565ad0359542748f2e93df36aae567fcd15236b212b70e64b5e1d417f88c8a617935a4acc1ae048592522da221cb0d890eb0efc4f9a808366d7f3
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
