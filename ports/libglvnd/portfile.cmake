vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
set(VCPKG_FIXUP_ELF_RPATH ON)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glvnd/libglvnd
    REF c7cdf0cc4395b57563294d1f340b6bb1b95366a0
    SHA512 3fda563239a9048c21c62005d074dafb79ec20213f8f02ffd8ac529d821a5ddb87ae44fb49159fce2a97581d9b7cff875ed7478621b6cf8191e2f5fd7f20a974
    HEAD_REF master
)

# TODO: Setup DEFAULT_EGL_VENDOR_CONFIG_DIRS
# TODO: Fix absolute paths in libX11.a (will get integrated in the so here)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dx11=enabled
        -Degl=true
        -Dgles1=true
        -Dgles2=true
        -Dglx=enabled
        -Dentrypoint-patching=enabled
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

# This needs some cleanup. Copyright is at end of README.md
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
