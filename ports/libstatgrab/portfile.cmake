vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libstatgrab/libstatgrab
    REF "LIBSTATGRAB_0_92_1"
    SHA512 8f631a40aaebbeaea593eff631529d583bd88a89cc910a97ad6cc2f01dc27333d05dfce95b325cf0833b9d5dded5fd92137b1d65425565ed45f801115f0100c3
    HEAD_REF master
    PATCHES
        configure.ac.patch
        disk_stats.c.patch
        globals.c.patch
        os_info.c.patch
        vector.c.patch
        opt.c.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-man
        --disable-saidar
        --disable-statgrab
        --disable-tests
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LGPL")
