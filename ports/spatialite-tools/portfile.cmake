# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

string(REPLACE "-" "" SPATIALITE_TOOLS_VERSION_STR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    FILENAME "spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    SHA512 cf255c9e04e78e450e20019e3c988b2b0a770c6b7857a5b1c95d0696ee29902e7a85667c1a38dec9aa164fa6d28a444be6365b0444b78015180c1f27fa68ea89
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-makefiles.patch
)
file(REMOVE "${SOURCE_PATH}/config.h")

set(PKGCONFIG_MODULES expat libxml-2.0 sqlite3)

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PKGCONFIG_MODULES readosm spatialite)
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax ${PKGCONFIG_MODULES}
        LIBS
    )

    # vcpkg_build_nmake doesn't supply cmake's implicit link libraries
    if(PKGCONFIG_LIBS_DEBUG MATCHES "libcrypto")
        string(APPEND PKGCONFIG_LIBS_DEBUG " user32.lib")
    endif()
    if(PKGCONFIG_LIBS_RELEASE MATCHES "libcrypto")
        string(APPEND PKGCONFIG_LIBS_RELEASE " user32.lib")
    endif()

    set(ICONV_LIBS "iconv.lib")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(APPEND ICONV_LIBS " charset.lib")
    endif()

    set(UWP_LIBS "")
    if(VCPKG_TARGET_IS_UWP)
        set(UWP_LIBS "windowsapp.lib /APPCONTAINER")
    endif()

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PREFER_JOM
        CL_LANGUAGE C
        OPTIONS_RELEASE
            "INSTDIR=${INST_DIR}"
            "LIBS_ALL=/link ${PKGCONFIG_LIBS_RELEASE} ${ICONV_LIBS} ${UWP_LIBS}"
        OPTIONS_DEBUG
            "INSTDIR=${INST_DIR}\\debug"
            "LIBS_ALL=/link ${PKGCONFIG_LIBS_DEBUG} ${ICONV_LIBS} ${UWP_LIBS}"
        )

    set(TOOL_EXES
        shp_sanitize
        spatialite_osm_filter
        spatialite_osm_raw
        spatialite_gml
        spatialite_osm_map
        exif_loader
        spatialite_osm_net
        spatialite_network
        spatialite_tool
        shp_doctor
        spatialite
    )
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_EXES} AUTO_CLEAN)

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

else()
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES ${PKGCONFIG_MODULES}
        LIBS
    )

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            --disable-minizip
            --disable-readline
            --enable-readosm
        OPTIONS_DEBUG
            "LIBS=${PKGCONFIG_LIBS_DEBUG} \$LIBS"
        OPTIONS_RELEASE
            "LIBS=${PKGCONFIG_LIBS_RELEASE} \$LIBS"
    )

    vcpkg_install_make()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
