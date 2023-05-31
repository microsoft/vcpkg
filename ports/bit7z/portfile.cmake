vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO rikyoz/bit7z
        REF v${VERSION}
        SHA512 daa1d5f051a2e07cbed07b81b1dcfa0cadc78a8cb12188e775d6d5f7a9344c40d0f02105c52c4079be58d9bcd6e4dd9c8a6fc01346a7d28824ab6a32e404db4e
        HEAD_REF master
        PATCHES
        0001-Fix-using-vcpkg-7z-package-and-install.patch
)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
        auto-format            BIT7Z_AUTO_FORMAT
        regex-matching         BIT7Z_REGEX_MATCHING
        use-std-byte           BIT7Z_USE_STD_BYTE
        use-native-string      BIT7Z_USE_NATIVE_STRING
        generate-pic           BIT7Z_GENERATE_PIC
        link-libcpp            BIT7Z_LINK_LIBCPP
        auto-prefix-long-paths BIT7Z_AUTO_PREFIX_LONG_PATHS
        )


vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
