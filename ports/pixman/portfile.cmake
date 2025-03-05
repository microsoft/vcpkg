if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        set(VCPKG_C_FLAGS "/arch:SSE2 ${VCPKG_C_FLAGS}")
    endif()
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(VCPKG_CXX_FLAGS "/arch:SSE2 ${VCPKG_CXX_FLAGS}")
    endif()
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
    REF "pixman-${VERSION}"
    SHA512 a878d866fbd4d609fabac6a5acac4d0a5ffd0226d926c09d3557261b770f1ad85b2f2d90a48b7621ad20654e52ecccbca9f1a57a36bd5e58ecbe59cca9e3f25d
    PATCHES
        no-host-cpu-checks.patch
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
