vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Exiv2/exiv2
    REF "v${VERSION}"
    SHA512 a7fa8fb19e54cdf0b9aac917087c86d45ea1b4a991a85ea8c5dd96af0289df63823901e44604d4c8df55883dcd19aee2efc48d7b5fde313dc0787b842a223a4a
    HEAD_REF master
    PATCHES
        dependencies.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bmff    EXIV2_ENABLE_BMFF
        nls     EXIV2_ENABLE_NLS
        png     EXIV2_ENABLE_PNG
        xmp     EXIV2_ENABLE_XMP
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DEXIV2_ENABLE_FILESYSTEM_ACCESS=OFF)
endif()

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
        -DEXIV2_ENABLE_VIDEO=OFF
        -DEXIV2_TEAM_EXTRA_WARNINGS=OFF
        -DEXIV2_TEAM_WARNINGS_AS_ERRORS=OFF
        -DEXIV2_TEAM_PACKAGING=OFF
        -DEXIV2_TEAM_USE_SANITIZERS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/exiv2)

if(VCPKG_TARGET_IS_OSX AND "nls" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/exiv2.pc" " -lintl" " -lintl -framework CoreFoundation")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/exiv2.pc" " -lintl" " -lintl -framework CoreFoundation")
    endif()
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/exiv2.pc" "Libs.private: " "Libs.private: -lpsapi ")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/exiv2.pc" "Libs.private: " "Libs.private: -lpsapi ")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
