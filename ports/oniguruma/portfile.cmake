vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkos/oniguruma
    REF v6.9.7.1
    SHA512 CE22050E04E51843E894D2D534D062FDD23CC2BAAC9BA43DA1843EC928F6CE5ED3D4407FE945F4D34ADADF3167DFD943CD81AE4556F7C5EC51E7331C35EAD479
    HEAD_REF master
    PATCHES fix-uwp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "non-posix" ENABLE_POSIX_API
)

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(MSVC_STATIC_RUNTIME ON)
else()
    set(MSVC_STATIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMSVC_STATIC_RUNTIME=${MSVC_STATIC_RUNTIME}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/oniguruma.h"
        "#if defined(ONIGURUMA_EXPORT)"
        "#if 0 // defined(ONIGURUMA_EXPORT)"
    )
else()
    # oniguruma.h uses `\n` as line break.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/oniguruma.h"
        "#ifndef ONIG_EXTERN\n#if defined(_WIN32) && !defined(__GNUC__)"
        "#if 0\n#if defined(_WIN32) && !defined(__GNUC__)"
    )
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
