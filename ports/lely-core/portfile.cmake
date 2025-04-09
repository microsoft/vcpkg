if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoconf\n    automake\n    libtool\n    \nThese can be installed on Ubuntu systems via apt-get install autoconf automake libtool")
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lely_industries/lely-core
    REF "v${VERSION}"
    SHA512 0beab1b5cbc987065c230c8dd5ac2aa16971712478ecb6ad25b3018fc80016f59305e87423fedca8561af5eba782107b418162cc03c568c559417747a64f8a46
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS 
        "--disable-cython"
        "--disable-python"
        "--disable-unit-tests"
        "--disable-tools"
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
