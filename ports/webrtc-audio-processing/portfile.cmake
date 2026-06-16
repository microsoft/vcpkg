vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "pulseaudio/webrtc-audio-processing"
    REF "v2.1"
    SHA512 6851bf40b62a8f642eaa5e3e108a8331f43c0d6eb5e6d351e3252d6869066c991bd9eca6ba3a7f762bdb44251a253da05cf15a76fc1c55ca815f5a4e39cf5d4a
    PATCHES
        # Fixed in master, not yet shipped: https://gitlab.freedesktop.org/pulseaudio/webrtc-audio-processing/-/commit/c8896801dfbfe03b56f85c1533abc077ff74a533
        fix-abseil-nullability-compat.patch

        # Fixed in master, not yet shipped: https://gitlab.freedesktop.org/pulseaudio/webrtc-audio-processing/-/commit/e9c78dc4712fa6362b0c839ad57b6b46dce1ba83
        fix-gcc15-missing-cstdint.patch

        # WebRTC typically builds with clang, but VCPKG typically builds with
        # MSVC on Windows. Avoid some clang-specific assembly code in that
        # scenario, with the same fallback used for x86.
        fix-asm-windows-arm.patch
)

set(MESON_OPTIONS "")
if(VCPKG_TARGET_IS_WINDOWS)
    # Designated initializers in the WebRTC source require C++20 on MSVC
    list(APPEND MESON_OPTIONS "-Dcpp_std=vc++20")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${MESON_OPTIONS}
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove bin dirs for static builds or non-Windows (no DLL)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")