vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/readosm-sources/readosm-${VERSION}.tar.gz"
    FILENAME "readosm-${VERSION}.tar.gz"
    SHA512 ec8516cdd0b02027cef8674926653f8bc76e2082c778b02fb2ebcfa6d01e21757aaa4fd5d5104059e2f5ba97190183e60184f381bfd592a635805aa35cd7a682
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
        pc-file.patch
)

set(pkg_config_modules expat zlib)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax ${pkg_config_modules}
        CFLAGS
        LIBS
    )

    # cherry-picked from Makefile.vc (CFLAGS) and nmake.opt (OPTFLAGS)
    set(CFLAGS "/fp:precise /W3 /D_CRT_SECURE_NO_WARNINGS -I. -Iheaders")
    set(WANT_LIB "readosm.lib")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        string(APPEND CFLAGS " /DDLL_EXPORT")
        set(WANT_LIB "readosm_i.lib")
    endif()

    set(SYSTEM_LIBS "")
    if(VCPKG_TARGET_IS_UWP)
        set(SYSTEM_LIBS "windowsapp.lib")
    endif()

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        CL_LANGUAGE C
        OPTIONS
            "WANT_LIB=${WANT_LIB}"
        OPTIONS_RELEASE
            "CFLAGS=${CFLAGS} ${PKGCONFIG_CFLAGS_RELEASE}"
            "LIBS=${PKGCONFIG_LIBS_RELEASE} ${SYSTEM_LIBS}"
            "INSTDIR=${INST_DIR}"
        OPTIONS_DEBUG
            "CFLAGS=${CFLAGS} ${PKGCONFIG_CFLAGS_DEBUG}"
            "LIBS=${PKGCONFIG_LIBS_DEBUG} ${SYSTEM_LIBS}"
            "INSTDIR=${INST_DIR}\\debug"
    )
    vcpkg_copy_pdbs()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/readosm.h" "#ifdef DLL_EXPORT" "#if 0")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/readosm.h" "#ifdef DLL_EXPORT" "#if 1")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/readosm.h" "__declspec(dllexport)" "__declspec(dllimport)")
    endif()

    set(infile "${SOURCE_PATH}/readosm.pc.in")
    set(outfile "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/readosm.pc")
    set(VERSION "${VERSION}")
    set(exec_prefix [[${prefix}]])
    set(libdir [[${prefix}/lib]])
    set(includedir [[${prefix}/include]])
    list(JOIN pkg_config_modules " " requires_private)
    configure_file("${infile}" "${outfile}" @ONLY)
    if(NOT DEFINED VCPKG_BUILD_TYPE)
        set(outfile "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/readosm.pc")
        set(includedir [[${prefix}/../include]])
        configure_file("${infile}" "${outfile}" @ONLY)
    endif()

else()
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES ${pkg_config_modules}
        LIBS
    )
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS_RELEASE
            "LIBS=${PKGCONFIG_LIBS_RELEASE} \$LIBS"
        OPTIONS_DEBUG
            "LIBS=${PKGCONFIG_LIBS_DEBUG} \$LIBS"
    )

    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
