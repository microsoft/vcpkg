set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO font/util
    REF "font-util-${VERSION}"
    SHA512 93285c2e8c5c01f069a7621dba0bbb1175c0ebbea27d521395b40f036443c162fc1948c4d3cb34fe6c509d1818d95ed7e6d38919e3f7857dfa53e388aadb9128
    HEAD_REF master
    PATCHES build.patch
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND VCPKG_C_FLAGS " /DNEED_BASENAME")
    list(APPEND VCPKG_CXX_FLAGS " /DNEED_BASENAME")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
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
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
endif()
