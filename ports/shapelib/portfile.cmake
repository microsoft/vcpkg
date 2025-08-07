vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/shapelib/shapelib-${VERSION}.zip"
    FILENAME "shapelib-${VERSION}.zip"
    SHA512 50859bbd1ea8808aa06cd112cc16cc77c1bd29d93129180818a5ea3a753b63de4039f232d1d9f13ebd7d076e427d10036e5f00775e633eb637da511625fa29bb
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        contrib     BUILD_SHAPELIB_CONTRIB
        tools       BUILD_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DBUILD_TESTING=OFF
        -DUSE_RPATH=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_APPS)
    vcpkg_copy_tools(
        TOOL_NAMES
            dbfadd
            dbfcreate
            dbfdump
            shpadd
            shpcreate
            shpdump
            shprewind
            shptreedump
        AUTO_CLEAN
    )
endif()
if(BUILD_SHAPELIB_CONTRIB)
    vcpkg_copy_tools(
        TOOL_NAMES
            csv2shp
            dbfcat
            dbfinfo
            Shape_PointInPoly
            shpcat
            shpcentrd
            shpdata
            shpdxf
            shpfix
            shpinfo
            shpsort
            shpwkb
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE-LGPL" "${SOURCE_PATH}/LICENSE-MIT"
    # Cf. web/license.html
    COMMENT [[
The core portions of the library are made available under two
possible licenses. The licensee can choose to use the code under
either the Library GNU Public License described in LICENSE-LGPL
or under the MIT license described in LICENSE-MIT.

Some auxiliary portions of Shapelib, notably some of the components
in the contrib directory come under slightly different license restrictions.
Check the source files that you are actually using for conditions.
]])
