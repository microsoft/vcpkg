set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES skip_rawcpp.patch)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO util/macros
    REF  b8766308d2f78bc572abe5198007cf7aeec9b761 #v1.19.3
    SHA512 dc7383b1579dc6ef0473161764096c8161f23a4c4ba2182e7abd7f73f443eb0520e02f1dfaaba2f8ebb43e0ed93c1e6e5e7cf517561476b858d2471a8ecaf907
    HEAD_REF master
    PATCHES ${PATCHES}
) 

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_make()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/")
if(NOT CMAKE_HOST_WIN32)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal/")
endif()

file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/util-macros/" "${CURRENT_PACKAGES_DIR}/share/xorg/util-macros")

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/xorg-macros.pc" _contents)
string(REPLACE "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}" _contents "${_contents}")
string(REPLACE "datarootdir=\${prefix}/share" "datarootdir=\${prefix}/share/xorg" _contents "${_contents}")
string(REPLACE "includedir=${CURRENT_INSTALLED_DIR}/include" "includedir=\${prefix}/include" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xorg-macros.pc" "${_contents}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/xorg-macros.pc")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig/xorg-macros.pc")
    file(READ "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig/xorg-macros.pc" _contents)
    string(REPLACE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_INSTALLED_DIR}/debug" _contents "${_contents}")
    string(REPLACE "datarootdir=\${prefix}/share}" "datarootdir=\${prefix}/share/xorg/debug}" _contents "${_contents}")
    string(REPLACE "includedir=${CURRENT_INSTALLED_DIR}/debug/include" "includedir=\${prefix}/../include" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/xorg-macros.pc" "${_contents}")
    if(NOT CMAKE_HOST_WIN32)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg/debug/")
    endif()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(RENAME  "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig/xorg-macros.pc")
    file(RENAME  "${CURRENT_PACKAGES_DIR}/debug/share/" "${CURRENT_PACKAGES_DIR}/share/xorg/debug/")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/xorg/debug/${PORT}/pkgconfig" "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig")
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
