set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) 

if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxtrans
    REF  3b5df889f58a99980a35a7b4a18eb4e7d2abeac4 #v1.4
    SHA512 d1a1ecd8aa07d19a8b4936a37109cecd0c965b859a17ea838835230f9326c1a353feef388052df03173562cbf0f3e3764146c3669b1928698cd55ccc4f92992c
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

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "")
endif()
