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
    REF  91b8526c1eeb2b45c21f091e890cb74cf6989ff6 # 0.43.2
    SHA512 cd4ea905a2287ae1ec25720ac90a72b2812dfeb6a5a82e3bbfcfeba91461229cde61b8bc6a5dfe5711f6b2937b3d3d4ade2b0c9a0290880c7d0cc4859344b542
    PATCHES
        no-host-cpu-checks.patch
        fix_clang-cl.patch
        missing_intrin_include.patch
)

# Meson install wrongly pkgconfig file!
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Ddemos=disabled
        -Dgtk=disabled
        -Dlibpng=enabled
        -Dtests=disabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.txt)
