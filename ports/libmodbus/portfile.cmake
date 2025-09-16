vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephane/libmodbus
    REF "v${VERSION}"
    SHA512 cb506d5b72b629591002450221ea512a067209ee60c588dc88c45494ea983af2c05c47b2d0ba7db02e46d7a30110547ec96f9f98d643756f9528a99291683f70
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
