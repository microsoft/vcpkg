if(VCPKG_TARGET_IS_LINUX)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    if (NOT EXISTS "/usr/include/libintl.h")
        message(FATAL_ERROR "Please use command \"sudo apt-get install gettext\" to install gettext on linux.")
    endif()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-gettext-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-gettext)
    return()
else()
    set(VCPKG_POLICY_ALLOW_RESTRICTED_HEADERS enabled)
endif()

#Based on https://github.com/winlibs/gettext

set(GETTEXT_VERSION 0.19)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz"
    FILENAME "gettext-${GETTEXT_VERSION}.tar.gz"
    SHA512 a5db035c582ff49d45ee6eab9466b2bef918e413a882019c204a9d8903cb3770ddfecd32c971ea7c7b037c7b69476cf7c56dcabc8b498b94ab99f132516c9922
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GETTEXT_VERSION}
    PATCHES
        0001-Fix-macro-definitions.patch
        0002-Fix-uwp-build.patch
        0003-Fix-win-unicode-paths.patch
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/config.win32.h
    ${CMAKE_CURRENT_LIST_DIR}/config.unix.h.in
    DESTINATION ${SOURCE_PATH}/gettext-runtime
)
file(REMOVE ${SOURCE_PATH}/gettext-runtime/intl/libgnuintl.h ${SOURCE_PATH}/gettext-runtime/config.h)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/libgnuintl.win32.h DESTINATION ${SOURCE_PATH}/gettext-runtime/intl)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/gettext-runtime
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-gettext TARGET_PATH share/unofficial-gettext)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gettext)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gettext/COPYING ${CURRENT_PACKAGES_DIR}/share/gettext/copyright)

vcpkg_copy_pdbs()
