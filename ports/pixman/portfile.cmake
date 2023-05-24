if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(VCPKG_CXX_FLAGS "/arch:SSE2 ${VCPKG_CXX_FLAGS}") # TODO: /arch: flag requires compiler check. needs to be MSVC
    set(VCPKG_C_FLAGS "/arch:SSE2 ${VCPKG_C_FLAGS}")
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    #x64 in general has all those intrinsics. (except for UWP for some reason)
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND OPTIONS
            #-Darm-simd=enabled does not work with arm64-windows
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "mips")
    list(APPEND OPTIONS
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND OPTIONS
                -Da64-neon=disabled
                -Darm-simd=disabled
                -Dneon=disabled
                )
endif()

if(VCPKG_TARGET_IS_OSX)
    # https://github.com/microsoft/vcpkg/issues/29168
    list(APPEND OPTIONS -Da64-neon=disabled)
endif()

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.freedesktop.org
    REPO pixman/pixman
    REF  37216a32839f59e8dcaa4c3951b3fcfc3f07852c # 0.42.2
    SHA512 b010b2c698ebc95f8a8566c915ccfb81a82c08f0ccda8b11ddff4818eae4b51b103021d5bae9f3d3bd20bf494433f5fcc6b76188226fe336919b0b347cdcb828
    PATCHES
        no-host-cpu-checks.patch
        fix_clang-cl.patch
        missing_intrin_include.patch
)

# Meson install wrongly pkgconfig file!
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Dlibpng=enabled
        -Dtests=disabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
