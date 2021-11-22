set(READOSM_VERSION_STR "1.1.0a")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/readosm-sources/readosm-${READOSM_VERSION_STR}.tar.gz"
    FILENAME "readosm-${READOSM_VERSION_STR}.tar.gz"
    SHA512 ec8516cdd0b02027cef8674926653f8bc76e2082c778b02fb2ebcfa6d01e21757aaa4fd5d5104059e2f5ba97190183e60184f381bfd592a635805aa35cd7a682
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
)

set(PKGCONFIG_MODULES expat zlib)

if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax ${PKGCONFIG_MODULES}
        LIBS
    )

    if(VCPKG_TARGET_IS_UWP)
        set(UWP_LIBS windowsapp.lib)
        set(UWP_LINK_FLAGS /APPCONTAINER)
    endif()

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS_RELEASE
            "INSTDIR=${INST_DIR}"
            "LINK_FLAGS=${UWP_LINK_FLAGS}"
            "LIBS_ALL=${PKGCONFIG_LIBS_RELEASE} ${UWP_LIBS}"
        OPTIONS_DEBUG
            "INSTDIR=${INST_DIR}\\debug"
            "LINK_FLAGS=${UWP_LINK_FLAGS} /debug"
            "LIBS_ALL=${PKGCONFIG_LIBS_DEBUG} ${UWP_LIBS}"
    )

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib")
    else()
        file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/readosm.lib")
        file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/readosm_i.lib" "${CURRENT_PACKAGES_DIR}/lib/readosm.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/readosm_i.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/readosm.lib")
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

else()
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES ${PKGCONFIG_MODULES}
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
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)