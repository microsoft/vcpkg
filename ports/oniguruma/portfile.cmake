vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkos/oniguruma
    REF "v${VERSION}"
    SHA512 7c89247d8504c635687dc61b39b39b5afefa4851b24409a8eab31273f1cbc88f3db89095ae4b135bd034147d2616c2e18fc74887300b89532eedeab75677f437
    HEAD_REF master
    PATCHES 
        fix-uwp.patch
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

vcpkg_fixup_pkgconfig()

# Note that onig-config is a shell script, not CMake configs, so
# vcpkg_cmake_config_fixup would be inappropriate
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/onig-config")
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/onig-config")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/onig-config")
endif()

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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include/")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
