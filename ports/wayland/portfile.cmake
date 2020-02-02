
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland
    REF  367d2985f3242d12c16a4f9074254584a8739d1f #1.17.92
    SHA512 1244d81bd07d7a4608b5546971b4182070b8caa52278ca6a5ac0f7cdf51f94000ff8015dc9f23ce9f686592d97e9a8b5c1daf64778c0ad05e99af19b3968240e
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dcmake_prefix_path="${CURRENT_INSTALLED_DIR}"
            -Ddtd_validation=false
            -Ddocumentation=false
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/wayland-scanner${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wayland-scanner${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(MAKE_DIRECTORY  "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/aclocal" "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wayland-scanner.pc")
file(READ "${_file}" _contents)
string(REPLACE "bindir=\${prefix}/bin" "bindir=\${prefix}/tools/${PORT}" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wayland-scanner.pc")
file(READ "${_file}" _contents)
string(REPLACE "bindir=\${prefix}/bin" "bindir=\${prefix}/../tools/${PORT}" _contents "${_contents}")
file(WRITE "${_file}" "${_contents}")

