set(MODPLUG_HASH 5a39f5913d07ba3e61d8d5afdba00b70165da81d)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(STATIC_PATCH "001-automagically-define-modplug-static.patch")
endif()

vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Konstanty/libmodplug
    REF ${MODPLUG_HASH}
    SHA512 c43bb3190b62c3a4e3636bba121b5593bbf8e6577ca9f2aa04d90b03730ea7fb590e640cdadeb565758b92e81187bc456e693fe37f1f4deace9b9f37556e3ba1
    PATCHES
        ${STATIC_PATCH}
        002-detect_sinf.patch
        003-use-static-cast-for-ctype.patch
        004-export-pkgconfig.patch  # https://github.com/Konstanty/libmodplug/pull/59
        005-fix-install-paths.patch # https://github.com/Konstanty/libmodplug/pull/61
)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
