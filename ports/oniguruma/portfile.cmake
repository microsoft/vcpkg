vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kkos/oniguruma
    REF e03900b038a274ee2f1341039e9003875c11e47d # v6.9.4
    SHA512 77772e3994acbdde86a7405d24423fff101061e24cc8cd85975d3ab092935fc91c0c3b991fe2fa9e9a857b5254db7d923256cdb29a2e2d8a3cdd41837ed690f6
    HEAD_REF master
    PATCHES fix-uwp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "non-posix" ENABLE_POSIX_API
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/oniguruma.h
        "#if defined(ONIGURUMA_EXPORT)"
        "#if 0 // defined(ONIGURUMA_EXPORT)"
    )
else()
    # oniguruma.h uses `\n` as line break.
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/oniguruma.h
        "#ifndef ONIG_EXTERN\n#if defined(_WIN32) && !defined(__GNUC__)"
        "#if 0\n#if defined(_WIN32) && !defined(__GNUC__)"
    )
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
