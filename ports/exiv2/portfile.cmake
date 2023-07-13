vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF "v${VERSION}"
    SHA512 7d7121770a9394efd31acb74709583e587351fc48c485a2f684cacce4ed19a2d07a6cb1cea986c16bf64851fd53b22a7277c1e1ae1a6cd69a5761afae3c5c731
    HEAD_REF master
    PATCHES
        fix-find_expat.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode EXIV2_ENABLE_WIN_UNICODE
        xmp     EXIV2_ENABLE_XMP
        video   EXIV2_ENABLE_VIDEO
        png     EXIV2_ENABLE_PNG
        nls     EXIV2_ENABLE_NLS
        bmff    EXIV2_ENABLE_BMFF
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" EXIV2_CRT_DYNAMIC)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXIV2_BUILD_EXIV2_COMMAND=OFF
        -DEXIV2_BUILD_UNIT_TESTS=OFF
        -DEXIV2_BUILD_SAMPLES=OFF
        -DEXIV2_BUILD_DOC=OFF
        -DEXIV2_ENABLE_EXTERNAL_XMP=OFF
        -DEXIV2_ENABLE_PRINTUCS2=OFF
        -DEXIV2_ENABLE_LENSDATA=ON
        -DEXIV2_ENABLE_DYNAMIC_RUNTIME=${EXIV2_CRT_DYNAMIC}
        -DEXIV2_ENABLE_WEBREADY=OFF
        -DEXIV2_ENABLE_CURL=OFF
        -DEXIV2_ENABLE_SSH=OFF
        -DEXIV2_TEAM_EXTRA_WARNINGS=OFF
        -DEXIV2_TEAM_WARNINGS_AS_ERRORS=OFF
        -DEXIV2_TEAM_PACKAGING=OFF
        -DEXIV2_TEAM_USE_SANITIZERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/exiv2)
vcpkg_fixup_pkgconfig()

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}
    @ONLY
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/exiv2"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/exiv2"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
