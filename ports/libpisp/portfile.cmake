vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raspberrypi/libpisp
    REF "v${VERSION}"
    SHA512 0a1669c0191cc5a77de0aeac889aaa30345831262e3b0b477410317a3e00e228991e8ad37a45969f788be527a753bf1cb6e67056820f33e77ef7925424e55c61
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST 
    "${SOURCE_PATH}/LICENSES/BSD-2-Clause.txt"
    "${SOURCE_PATH}/LICENSES/CC0-1.0.txt"
    "${SOURCE_PATH}/LICENSES/GPL-2.0-only.txt"
    "${SOURCE_PATH}/LICENSES/GPL-2.0-or-later.txt"
    "${SOURCE_PATH}/LICENSES/Linux-syscall-note.txt"
    "${SOURCE_PATH}/LICENSES/MIT.txt"
)
