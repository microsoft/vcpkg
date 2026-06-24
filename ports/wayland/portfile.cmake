vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "force-build" FORCE_BUILD
        "scanner" SCANNER
)

if(NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT FORCE_BUILD AND NOT SCANNER)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()


if(FORCE_BUILD AND NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES)
    message(FATAL_ERROR "To build wayland libraries the `force-build` feature must be enabled and the X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES triplet variable must be set.")
endif()
if(X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT FORCE_BUILD AND NOT SCANNER)
    message(FATAL_ERROR "To build wayland libraries the `force-build` feature must be enabled and the X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES triplet variable must be set.")
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

set(BUILD_LIBRARIES false)
if(FORCE_BUILD)
    set(BUILD_LIBRARIES true)
endif()

set(BUILD_SCANNER false)
if(SCANNER)
    set(BUILD_SCANNER true)
endif()
if(FORCE_BUILD AND NOT VCPKG_CROSSCOMPILING)
    set(BUILD_SCANNER true)
endif()

set(BINARIES "")
set(OPTIONS
    -Dlibraries=${BUILD_LIBRARIES}
    -Dscanner=${BUILD_SCANNER}
)
if(FORCE_BUILD AND VCPKG_CROSSCOMPILING)
    list(APPEND BINARIES "wayland_scanner = ['${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/wayland-scanner${VCPKG_HOST_EXECUTABLE_SUFFIX}']")
    list(APPEND OPTIONS -Dscanner=false)
endif()

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

if(BUILD_SCANNER)
    vcpkg_copy_tools(TOOL_NAMES wayland-scanner AUTO_CLEAN)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/tools/${PORT}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/../tools/${PORT}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
