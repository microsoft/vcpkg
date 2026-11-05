vcpkg_download_distfile(ARCHIVE
    URLS "https://oligarchy.co.uk/xapian/${VERSION}/xapian-core-${VERSION}.tar.xz"
    FILENAME "xapian-core-${VERSION}.tar.xz"
    SHA512 a3c650de333a0b6ba81f47df01d433a8fb86007a33e61509c7ceead822aa5104261fc539619054be8bed8721eff3cdd70a33bb06f6180a1fd7995642133d5ee9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        msvc-no-debug.diff
)

set(OPTIONS "")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    list(APPEND OPTIONS
        ac_cv_have_decl___popcnt=no
        ac_cv_have_decl___popcnt64=no
    )
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    USE_WRAPPERS
    OPTIONS
        ${OPTIONS}
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/xapian)

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}\"" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}/debug\"" "`dirname $0`/../../../../debug")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
