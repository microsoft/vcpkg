vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ttmath
    REF ttmath/ttmath-0.9.3
    FILENAME "ttmath-0.9.3-src.tar.gz"
    SHA512 ee5f56e92476c4d77c40beae1a2bd4d62fde2e9450b46184a2e37f2c52fc7d69ccac5688974a05aef68517b812515eb74a8992dd5d0104e57a32bf6e905c14e3
    PATCHES
        disable-msvc-x64-asm.patch
)

file(INSTALL "${SOURCE_PATH}/ttmath" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
