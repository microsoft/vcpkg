set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # only executables

string(REPLACE "-" "" SPATIALITE_TOOLS_VERSION_STR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    FILENAME "spatialite-tools-${SPATIALITE_TOOLS_VERSION_STR}.tar.gz"
    SHA512 cf255c9e04e78e450e20019e3c988b2b0a770c6b7857a5b1c95d0696ee29902e7a85667c1a38dec9aa164fa6d28a444be6365b0444b78015180c1f27fa68ea89
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        android-builtin-iconv.diff
        configure.diff
        fix-makefiles.patch
)
file(REMOVE "${SOURCE_PATH}/config.h")

if (VCPKG_TARGET_IS_WINDOWS)
    x_vcpkg_pkgconfig_get_modules(
        PREFIX PKGCONFIG
        MODULES --msvc-syntax expat libxml-2.0 readosm spatialite sqlite3
        LIBS
    )

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PREFER_JOM
        CL_LANGUAGE C
        OPTIONS_RELEASE
            "INSTDIR=${INST_DIR}"
            "LIBS_ALL=/link ${PKGCONFIG_LIBS_RELEASE} iconv.lib charset.lib user32.lib"
        OPTIONS_DEBUG
            "INSTDIR=${INST_DIR}\\debug"
            "LIBS_ALL=/link ${PKGCONFIG_LIBS_DEBUG} iconv.lib charset.lib user32.lib"
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
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            --disable-minizip
            --disable-readline
            --enable-readosm
    )
    vcpkg_make_install()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
