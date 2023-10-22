set(LIBOSIP2_VER "5.2.0")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz"
    FILENAME "libosip2-${LIBOSIP2_VER}.tar.gz"
    SHA512 cc714ab5669c466ee8f0de78cf74a8b7633f3089bf104c9c1474326840db3d791270159456f9deb877af2df346b04493e8f796b2bb7d2be134f6c08b25a29f83
)

set(PATCHES)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PATCHES fix-path-in-project.patch)
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Use /Z7 rather than /Zi to avoid "fatal error C1090: PDB API call failed, error code '23': (0x00000006)"
    foreach(VCXPROJ IN ITEMS
        "${SOURCE_PATH}/platform/vsnet/osip2.vcxproj"
        "${SOURCE_PATH}/platform/vsnet/osipparser2.vcxproj")
        vcpkg_replace_string(
            "${VCXPROJ}"
            "<DebugInformationFormat>ProgramDatabase</DebugInformationFormat>"
            "<DebugInformationFormat>OldStyle</DebugInformationFormat>"
        )
    endforeach()

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "platform/vsnet/osip2.vcxproj"
    )

    file(COPY "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" PATTERN Makefile.* EXCLUDE)

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "platform/vsnet/osipparser2.vcxproj"
    )

elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}")
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
