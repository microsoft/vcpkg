vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "force-build" FORCE_BUILD
        "scanner" BUILD_SCANNER
)

if(NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT FORCE_BUILD AND NOT BUILD_SCANNER)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()


if(FORCE_BUILD AND NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES)
    message(FATAL_ERROR "To build wayland libraries with the `force-build` feature, the X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES triplet variable must be set.")
endif()
if(X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT FORCE_BUILD AND NOT BUILD_SCANNER)
    message(FATAL_ERROR "To build wayland libraries the `force-build` feature must be enabled and the X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES triplet variable must be set.")
endif()
if(BUILD_SCANNER AND NOT FORCE_BUILD)
    # wayland[scanner] is a tool-only build; headers are installed only with the libraries.
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland
    REF  ${VERSION}
    SHA512 24c8cb42598d0d0d78831b200630cb2254c81241661b7977f30d4d733f6efceac91768784db64d0991e2044adf04049a6d3f5b27a5d9ceab8605dd89589abb68
    HEAD_REF master
    PATCHES
        cross-build.diff
)

set(BINARIES "")

# vcpkg feature variables are CMake booleans (ON/OFF), but Meson boolean options
# require true/false. Translate them here before passing them to meson setup.
set(MESON_BUILD_LIBRARIES false)
if(FORCE_BUILD)
    set(MESON_BUILD_LIBRARIES true)
endif()

set(MESON_BUILD_SCANNER false)
if(BUILD_SCANNER OR (FORCE_BUILD AND NOT VCPKG_CROSSCOMPILING))
    set(MESON_BUILD_SCANNER true)
endif()
if(FORCE_BUILD AND VCPKG_CROSSCOMPILING)
    list(APPEND BINARIES "wayland_scanner = ['${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/wayland-scanner${VCPKG_HOST_EXECUTABLE_SUFFIX}']")
    set(MESON_BUILD_SCANNER false)
endif()
set(OPTIONS
    -Dlibraries=${MESON_BUILD_LIBRARIES}
    -Dscanner=${MESON_BUILD_SCANNER}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Ddocumentation=false
        -Ddtd_validation=false
        -Dtests=false
    ADDITIONAL_BINARIES
        ${BINARIES}
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if(MESON_BUILD_SCANNER)
    vcpkg_copy_tools(TOOL_NAMES wayland-scanner AUTO_CLEAN)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/tools/${PORT}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/../tools/${PORT}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
