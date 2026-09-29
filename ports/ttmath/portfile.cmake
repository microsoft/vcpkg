vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://gitea.ttmath.org/tomasz.sowa/ttmath.git"
    REF aad580f51e7ffc32966507a9897ec575c389e3e6
    PATCHES
        disable-msvc-x64-asm.patch
)

file(INSTALL "${SOURCE_PATH}/ttmath" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
