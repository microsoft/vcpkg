vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephane/libmodbus
    REF "v${VERSION}"
    SHA512 63f9a4ae2096f684a0adcc1d33f1b9090d0d531934944ef506106d11da760141b27d5916d59b3e1aa0d78def5c2673984b2aa43ebe4521aaa55f439f32dd7475
    HEAD_REF master
    PATCHES
        cflags.diff
        library-linkage.diff
        pkgconfig.diff
        ssize_t.diff
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
