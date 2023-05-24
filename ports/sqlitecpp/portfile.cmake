vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF 3.2.0
    HEAD_REF master
    SHA512 af57c3e82a8804174c52105ecc14ea7a2d4e293ef13b2fc371f2455890ea54683ed76adf4649e561686a6b4c3368676f5edcc54d9f22c4850be3ba32832d3272
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLITECPP_RUN_CPPLINT=OFF
        -DSQLITECPP_RUN_CPPCHECK=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
        -DSQLITE_ENABLE_COLUMN_METADATA=ON
        -DSQLITECPP_INTERNAL_SQLITE=OFF
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
