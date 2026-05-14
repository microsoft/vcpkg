# zvbi has no __declspec(dllexport) annotations, so static only on Windows.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zapping-vbi/zvbi
    REF v0.2.44
    SHA512 74b7d44faf42f919ebd3ccb69f8567f56909075d3acf4a3b4dfcbdf85489492f27d8a04173e0010f59706356e4078cd10911945f87e2596de2b897672d1e55cb
    HEAD_REF main
    PATCHES
        patches/001-msvc-compat.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    # autopoint (gettext) is not available in vcpkg's msys2 environment, but the NLS support is disabled anyway, so skip the autopoint step.
    set(ENV{AUTOPOINT} true)
else(VCPKG_TARGET_IS_WINDOWS)
    # The MSVC-compat patch creates Windows-only shim headers that shadow POSIX equivalents.
    # Remove them so the autotools build uses the real system headers on Unix/macOS.
    file(REMOVE "${SOURCE_PATH}/src/unistd.h")
    file(REMOVE "${SOURCE_PATH}/src/strings.h")
    file(REMOVE_RECURSE "${SOURCE_PATH}/src/sys")
endif(VCPKG_TARGET_IS_WINDOWS)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --disable-nls
        --disable-examples
        --disable-tests
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

# Remove tools (not needed; avoids RPATH/headerpad issues on macOS).
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
