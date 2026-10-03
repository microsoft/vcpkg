vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephane/libmodbus
    REF "v${VERSION}"
    SHA512 39135c318d4785e9a3493ba37f13b8da5addb55ac0914990247fac08a332f22a8d6a38023849618db32af19ce5c7831042a212c4d43c9e355aa27e23e85d65be
    HEAD_REF master
    PATCHES
        cflags.diff
        library-linkage.diff
        pkgconfig.diff
        ssize_t.diff
        fdsetsize-win32.diff
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{WARNING_CFLAGS} "-D_CRT_SECURE_NO_DEPRECATE=1 -D_CRT_NONSTDC_NO_DEPRECATE=1")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --enable-tests=no
)
vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
file(COPY "${CURRENT_PORT_DIR}/libmodbusConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libmodbus")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/modbus/modbus.h" "defined(STATIC_LIBMODBUS)" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")
