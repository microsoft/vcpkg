vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF 3.1.1
    HEAD_REF master
    SHA512 9030b5249c149db8a5b2fe350f71613e4ee91061765a771640ed3ffa7c24aada4000ba884ef91790fdc0f13dc4519038c1edeba64b85b85ac09c3e955a7988a1
    PATCHES
        0001-unofficial-sqlite3-and-sqlcipher.patch
        fix_dependency.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
	sqlcipher SQLITE_HAS_CODEC
)
set(USE_STACK_PROTECTION "")
if(VCPKG_TARGET_IS_MINGW)
    set(USE_STACK_PROTECTION "-DSQLITECPP_USE_STACK_PROTECTION=OFF")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLITECPP_RUN_CPPLINT=OFF
        -DSQLITECPP_RUN_CPPCHECK=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
        -DSQLITE_ENABLE_COLUMN_METADATA=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
        ${USE_STACK_PROTECTION}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SQLiteCpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
