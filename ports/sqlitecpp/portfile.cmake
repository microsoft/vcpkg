vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF ${VERSION}
    HEAD_REF master
    SHA512 23193108faaca4c1c7b0a05178bfdbb772a4e14dc145af1b3a7b35efe05a94b07200bdd5551afde44ab5eb3c6aeabbd70cfb0d710dc2750a8280e06fba94c494
    PATCHES
        fix_dependency.patch
        add_runtime_destination.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlcipher SQLITE_HAS_CODEC
)

set(USE_STACK_PROTECTION "")
if(VCPKG_TARGET_IS_MINGW)
    set(USE_STACK_PROTECTION "-DSQLITECPP_USE_STACK_PROTECTION=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLITECPP_RUN_CPPLINT=OFF
        -DSQLITECPP_RUN_CPPCHECK=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
        -DSQLITE_ENABLE_COLUMN_METADATA=ON
        -DSQLITECPP_USE_STATIC_RUNTIME=OFF # unconditionally off because vcpkg's toolchains already do the right thing
        # See https://github.com/SRombauts/SQLiteCpp/blob/e74403264ec7093060f4ed0e84bc9208997c8344/CMakeLists.txt#L40-L46
        ${USE_STACK_PROTECTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SQLiteCpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
