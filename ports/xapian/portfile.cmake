vcpkg_download_distfile(ARCHIVE
    URLS "https://oligarchy.co.uk/xapian/${VERSION}/xapian-core-${VERSION}.tar.xz"
    FILENAME "xapian-core-${VERSION}.tar.xz"
    SHA512 60d66adbacbd59622d25e392060984bd1dc6c870f9031765f54cb335fb29f72f6d006d27af82a50c8da2cfbebd08dac4503a8afa8ad51bc4e6fa9cb367a59d29
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        configure.diff
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
