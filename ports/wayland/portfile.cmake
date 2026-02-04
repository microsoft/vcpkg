vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "force-build" FORCE_BUILD
)

if(NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT FORCE_BUILD)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()


if(NOT FORCE_BUILD OR NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES)
    message(FATAL_ERROR "To build wayland libraries the `force-build` feature must be enabled and the X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES triplet variable must be set.")
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland
    REF  ${VERSION}
    SHA512 454a4d7cab9fb9eafe3505114e9dfafed94c985fb7f156eb2d67f258bf2bf8418598ab75c237aa75fabe81a811981dbc72363870f2f81ddcbfb3adfaa95d4947
    HEAD_REF master
    PATCHES
        cross-build.diff
)

set(BINARIES "")
set(OPTIONS "")
if(VCPKG_CROSSCOMPILING)
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

if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(TOOL_NAMES wayland-scanner AUTO_CLEAN)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/tools/${PORT}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wayland-scanner.pc" "bindir=\${prefix}/bin" "bindir=\${prefix}/../tools/${PORT}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
