vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/shapelib/shapelib-${VERSION}.zip"
    FILENAME "shapelib-${VERSION}.zip"
    SHA512 f3f43f2028fe442e020558de2559b24eae9c7a1d0c84cc242f23ea985cf1fb5ff39fbfef7738f9b8ef5df9a5d0b9f3e891a61b3d5fbbe5b224f41a46589723a3
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        contrib     BUILD_SHAPELIB_CONTRIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

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
