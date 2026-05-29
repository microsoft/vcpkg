set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(
    FONTUTIL_ARCHIVE
    URLS "https://www.x.org/archive//individual/font/font-util-${VERSION}.tar.xz"
    FILENAME "font-util-${VERSION}.tar.xz"
    SHA512 3def5f08bcb30ec3e0008f648478ebe1f65127d03e821613de550e95247812751b4ff31383739ad120123b2f69c87d819c18d44d1edee2ca51075a3c031e3a6f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${FONTUTIL_ARCHIVE}"
    PATCHES
        build.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND VCPKG_C_FLAGS " /DNEED_BASENAME")
    list(APPEND VCPKG_CXX_FLAGS " /DNEED_BASENAME")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/fonts/" "${CURRENT_PACKAGES_DIR}/share/xorg/fonts")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/debug")

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/fontutil.pc")
file(READ "${_file}" _contents)
string(REPLACE "datarootdir=\${prefix}/share/${PORT}" "datarootdir=\${prefix}/share/xorg" _contents "${_contents}")
string(REPLACE "exec_prefix=\${prefix}" "exec_prefix=\${prefix}/tools/${PORT}" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

if(NOT VCPKG_BUILD_TYPE)
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/fontutil.pc")
    file(READ "${_file}" _contents)
    string(REPLACE "datarootdir=\${prefix}/share/${PORT}" "datarootdir=\${prefix}/../share/xorg" _contents "${_contents}")
    string(REPLACE "exec_prefix=\${prefix}" "exec_prefix=\${prefix}/../tools/${PORT}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
