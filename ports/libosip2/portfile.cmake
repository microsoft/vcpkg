vcpkg_download_distfile(ARCHIVE
    URLS
        "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/osip/libosip2-${VERSION}.tar.gz"
        "https://ftp.gnu.org/gnu/osip/libosip2-${VERSION}.tar.gz"
    FILENAME "libosip2-${VERSION}.tar.gz"
    SHA512 cd9db7a736cca90c6862b84c4941ef025f5affab8af9bbc02ce0dd3310a2c555e0922c1bfa72d8ac08791fa1441bbcc30b627d52ca8b51f3471573a10ac82a00
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

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
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

else()
    vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}")
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
