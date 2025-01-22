set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)

# Requirements from https://github.com/besser82/libxcrypt?tab=readme-ov-file#build-requirements-and-instructions
message(
"${PORT} currently requires the following libraries from the system package manager:
    autoconf automake libtool pkg-config
These can be installed on Debian systems via sudo apt install autoconf automake libtool pkg-config"
)
find_program(AUTORECONF_BIN autoreconf)
if(NOT AUTORECONF_BIN)
    message(FATAL_ERROR "${PORT} requires autoconf from the system package manager (example: \"sudo apt install autoconf\")")
endif()
find_program(LIBTOOL_BIN libtoolize)
if(NOT LIBTOOL_BIN)
    message(FATAL_ERROR "${PORT} requires libtool from the system package manager (example: \"sudo apt install libtool\")")
endif()

vcpkg_download_distfile(PATCH_FIX_ERROR_STRICT_OVERFLOW
    URLS https://github.com/besser82/libxcrypt/commit/7fc153170ea6c2938c0392794778de7ec995f8f9.patch?full_index=1
    SHA512 55f4709c52f6d0a29f159348821c06e3f5df0fae83f487b7a52ce61cd3f6a3a0f48023159fb7029d0a5a3decee36ac6a429cc91e23a83996a3265d681fa11929
    FILENAME besser82-libxcrypt-7fc153170ea6c2938c0392794778de7ec995f8f9.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO besser82/libxcrypt
    REF "v${VERSION}"
    SHA512 61e5e393654f37775457474d4170098314879ee79963d423c1c461e80dc5dc74f0c161dd8754f016ce96109167be6c580ad23994fa1d2c38c54b96e602f3aece
    PATCHES
        "${PATCH_FIX_ERROR_STRICT_OVERFLOW}"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSING" "${SOURCE_PATH}/COPYING.LIB")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
