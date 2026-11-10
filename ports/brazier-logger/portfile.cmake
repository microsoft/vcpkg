vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier-logger
    REF "v${VERSION}"
    SHA512 728d52e8d851b42b7940a21cdbacf8876b30fbab9c3e488722da05d662630b25d6aea9a623568658ba9e117ab47f75065c3870975f312e3616aba2dafe61bc09
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
)
