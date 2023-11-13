vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF "v${VERSION}"
    SHA512 35e483c6123f099167ed8647fae7c6e5512434c24d0afe684180ba6a5114068d5678280a01c8e6cfee0d1e555e1dc2a1606989d46950ce3ef1a3859caeed4dad
    HEAD_REF master
    PATCHES
        fix-find_expat.patch
        fix-inih.patch
        fix-brotli.patch
        fix-expat.patch
        dont-find-python.patch
        ios.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
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
        -DEXIV2_ENABLE_LENSDATA=ON
        -DEXIV2_ENABLE_DYNAMIC_RUNTIME=${EXIV2_CRT_DYNAMIC}
        -DEXIV2_ENABLE_WEBREADY=OFF
        -DEXIV2_ENABLE_CURL=OFF
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

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
