vcpkg_download_distfile(ARCHIVE
    URLS "https://oligarchy.co.uk/xapian/${VERSION}/xapian-core-${VERSION}.tar.xz"
    FILENAME "xapian-core-${VERSION}.tar.xz"
    SHA512 a3c650de333a0b6ba81f47df01d433a8fb86007a33e61509c7ceead822aa5104261fc539619054be8bed8721eff3cdd70a33bb06f6180a1fd7995642133d5ee9
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

if(VCPKG_TARGET_IS_WINDOWS)
    # Upstream's cmake/xapian-config.cmake.in hardcodes unix-style library names
    # (libxapian.lib / libxapian.dll.lib); on Windows the library is xapian.lib
    # (the import library of bin/xapian-*.dll). Point at the real file and make
    # the selection configuration-appropriate (Debug uses debug/lib).
    set(XAPIAN_CMAKE_CONFIG "${CURRENT_PACKAGES_DIR}/share/xapian/xapian-config.cmake")
    vcpkg_replace_string("${XAPIAN_CMAKE_CONFIG}"
        "\"\${prefix}/lib/libxapian.lib\""
        "\"$<$<CONFIG:Debug>:\${prefix}/debug/lib/xapian.lib>$<$<NOT:$<CONFIG:Debug>>:\${prefix}/lib/xapian.lib>\"")
    vcpkg_replace_string("${XAPIAN_CMAKE_CONFIG}"
        "\"\${prefix}/lib/libxapian.dll.lib\""
        "\"$<$<CONFIG:Debug>:\${prefix}/debug/lib/xapian.lib>$<$<NOT:$<CONFIG:Debug>>:\${prefix}/lib/xapian.lib>\"")
    # On MinGW the prefix may be stored in MSYS form (/c/...); make it relocatable too.
    file(TO_CMAKE_PATH "${CURRENT_PACKAGES_DIR}" XAPIAN_PACKAGES_DIR)
    string(REGEX REPLACE "^([A-Za-z]):/(.*)$" "/\\1/\\2" XAPIAN_PACKAGES_DIR_MSYS "${XAPIAN_PACKAGES_DIR}")
    vcpkg_replace_string("${XAPIAN_CMAKE_CONFIG}" "${XAPIAN_PACKAGES_DIR_MSYS}" "\${VCPKG_IMPORT_PREFIX}" IGNORE_UNCHANGED)
    file(READ "${XAPIAN_CMAKE_CONFIG}" XAPIAN_CMAKE_CONFIG_CONTENTS)
    if(NOT XAPIAN_CMAKE_CONFIG_CONTENTS MATCHES "get_filename_component\\(VCPKG_IMPORT_PREFIX")
        string(PREPEND XAPIAN_CMAKE_CONFIG_CONTENTS "get_filename_component(VCPKG_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)\n")
        file(WRITE "${XAPIAN_CMAKE_CONFIG}" "${XAPIAN_CMAKE_CONFIG_CONTENTS}")
    endif()
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}\"" "`dirname $0`/../../..")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/xapian-config" "\"${CURRENT_INSTALLED_DIR}/debug\"" "`dirname $0`/../../../../debug")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/unicode/UnicodeData-README.txt")
