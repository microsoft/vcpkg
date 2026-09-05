# only executables
set(VCPKG_BUILD_TYPE release)
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

    # cherry-picked from makefile.vc (CFLAGS) and nmake.opt (OPTFLAGS)
    set(CFLAGS "/fp:precise /W3 /D_CRT_SECURE_NO_WARNINGS /D_LARGE_FILE=1 /D_FILE_OFFSET_BITS=64 /D_LARGEFILE_SOURCE=1")

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
    list(TRANSFORM TOOL_EXES APPEND ".exe" OUTPUT_VARIABLE TARGETS)

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}" INST_DIR)

    vcpkg_install_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        CL_LANGUAGE C
        # Use this explicit sequence of targets to mitigate linker race.
        TARGET ${TARGETS} install
        OPTIONS_RELEASE
            "CFLAGS=${CFLAGS} ${PKGCONFIG_CFLAGS_RELEASE}"
            "LIBS=${PKGCONFIG_LIBS_RELEASE} iconv.lib charset.lib user32.lib"
            "INSTDIR=${INST_DIR}"
        OPTIONS_DEBUG
            --DISABLED--
    )

    vcpkg_copy_tools(TOOL_NAMES ${TOOL_EXES} AUTO_CLEAN)

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
