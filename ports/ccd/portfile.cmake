if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(STATIC_PATCH fix-static.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danfis/libccd
    REF v2.1
    SHA512 ff037d9c4df50f09600cf9b3514b259b2850ff43f74817853f5665d22812891168f70bd3cc3969b2c9e3c706f6254991a65421476349607fbd04d894b217456d
    HEAD_REF master
    # Backport https://github.com/danfis/libccd/pull/70 to support Emscripten
    PATCHES
        "support-emscripten.patch"
        ${STATIC_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        double-precision     ENABLE_DOUBLE_PRECISION
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/ccd)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(INSTALL "${SOURCE_PATH}/BSD-LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
