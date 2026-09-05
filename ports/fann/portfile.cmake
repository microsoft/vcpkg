vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfann/fann
    REF 8409b42d308bf9428b9d3e60927595e53a797bbc
    SHA512 4ad66808d7c88911d4c6d63368240ece2d0cbc73d89a95d32261b95dc551c47c46b3a34cc81b8cb0e03fe3f9ea61cb304e028780357bcf332d660824b066fd1e
    HEAD_REF master
    PATCHES
        fix-installation.patch
        fix-uwp-build.patch
        fix-build_type.patch
        remove-nouse-target.patch
)

set(INSTALL_BASE_DIR_DBG "${CURRENT_PACKAGES_DIR}/debug")
set(INSTALL_BASE_DIR_REL "${CURRENT_PACKAGES_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DBIN_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/bin
        -DSBIN_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/sbin
        -DLIB_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/lib
        -DEXEC_INSTALL_PREFIX=${INSTALL_BASE_DIR_DBG}/tools/${PORT}
        -DXDG_APPS_DIR=${INSTALL_BASE_DIR_DBG}/tools/${PORT}
        -DPLUGIN_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/tools/${PORT}
        -DINCLUDE_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/include
        -DSHARE_INSTALL_PREFIX=${INSTALL_BASE_DIR_DBG}/share/${PORT}
        -DDATA_INSTALL_PREFIX=${INSTALL_BASE_DIR_DBG}/share/${PORT}
        -DHTML_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/doc
        -DICON_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/data/icons
        -DSOUND_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/sounds
        -DLOCALE_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/locale
        -DSYSCONF_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/etc
        -DINFO_INSTALL_DIR=${INSTALL_BASE_DIR_DBG}/share/${PORT}/info
    OPTIONS_RELEASE
        -DBIN_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/bin
        -DSBIN_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/sbin
        -DLIB_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/lib
        -DEXEC_INSTALL_PREFIX=${INSTALL_BASE_DIR_REL}/tools/${PORT}
        -DXDG_APPS_DIR=${INSTALL_BASE_DIR_REL}/tools/${PORT}
        -DPLUGIN_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/tools/${PORT}
        -DINCLUDE_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/include
        -DSHARE_INSTALL_PREFIX=${INSTALL_BASE_DIR_REL}/share/${PORT}
        -DDATA_INSTALL_PREFIX=${INSTALL_BASE_DIR_REL}/share/${PORT}
        -DHTML_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/doc
        -DICON_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/data/icons
        -DSOUND_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/sounds
        -DLOCALE_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/locale
        -DSYSCONF_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/etc
        -DINFO_INSTALL_DIR=${INSTALL_BASE_DIR_REL}/share/${PORT}/info
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
