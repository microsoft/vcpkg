set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "force-build" FORCE_BUILD
        "generated-headers" GENERATED_HEADERS
)

set(GENERATED_HEADERS_OPTION false)
set(BINARIES "")
set(WAYLAND_SCANNER "${CURRENT_HOST_INSTALLED_DIR}/tools/wayland/wayland-scanner${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if(FORCE_BUILD OR GENERATED_HEADERS)
    set(GENERATED_HEADERS_OPTION true)
endif()
if(FORCE_BUILD OR (GENERATED_HEADERS AND EXISTS "${WAYLAND_SCANNER}"))
    list(APPEND BINARIES "wayland_scanner = ['${WAYLAND_SCANNER}']")
elseif(GENERATED_HEADERS)
    if(VCPKG_HOST_IS_WINDOWS OR VCPKG_HOST_IS_OSX OR VCPKG_TARGET_IS_ANDROID)
        message(WARNING "${PORT}[generated-headers] requires a host wayland-scanner provided outside vcpkg on this platform, either as a Meson native-file binary named wayland_scanner or as wayland-scanner on PATH.")
    endif()
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland-protocols
    REF "${VERSION}"
    SHA512 fa26b76b3e75bb52d56d924e66bf1d684bc6704b1b08b2801a0f9f376995e358f08f1bfaeaa9095c4a6e91c085ea87536beae9cfd43e350f60891601cb2a9d98
    HEAD_REF main
    PATCHES
        generated-headers-option.diff
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgenerated_headers=${GENERATED_HEADERS_OPTION}
        -Dtests=false
    ADDITIONAL_BINARIES
        ${BINARIES}
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
