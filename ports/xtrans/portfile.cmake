set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/xorg"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "lib/libxtrans"
    REF  "xtrans-${VERSION}"
    SHA512 c7037cb6d2fb641486a43c9203949edec2038735ba758f8556add63598dbb3205166a2ec272700639884b1952642c171806e3dab566722cadd4c71ca98c0a1bf
    HEAD_REF master
    PATCHES win32.patch
            symbols.patch
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/xorg")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# the include folder is moved since it contains source files. It is not meant as a traditional include folder but as a shared files folder for different x libraries.
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/share/${PORT}/include")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal/" "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/" "${CURRENT_PACKAGES_DIR}/share/xorg/debug")
endif()
vcpkg_fixup_pkgconfig() # must be called after files have been moved
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xtrans.pc" "includedir=\${prefix}/include" "includedir=\${prefix}/share/${PORT}/include")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xtrans.pc" "includedir=\${prefix}/../include" "includedir=\${prefix}/../share/${PORT}/include")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "")
endif()
