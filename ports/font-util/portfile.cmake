set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO font/util
    REF  d45011b8324fecebb4fc79e57491d341dd96e325 #1.3.2
    SHA512 d783cbb5b8b0975891a247f98b78c2afadfd33e1d26ee8bcf7ab7ccc11615b0150d07345c719182b0929afc3c54dc3288a01a789b5374e18aff883ac23d15b04
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
