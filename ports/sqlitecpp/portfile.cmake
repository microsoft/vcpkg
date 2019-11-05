include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF 09dd10886c560ab5af41cfe694567f34c88cd101
    HEAD_REF master
    SHA512 d0a440e2e96fca9aac7fe73d46bb6508825a82547dca1e9c93d8c3ca46878fa137e7a2a7a865bcfa641d0236e26307a3342d55fc83578552a37eec7565642d91
    PATCHES
        0001-Find-external-sqlite3.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSQLITECPP_RUN_CPPLINT=OFF
        -DSQLITECPP_RUN_CPPCHECK=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
        -DSQLITE_ENABLE_COLUMN_METADATA=OFF
        -DSQLITECPP_INTERNAL_SQLITE=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SQLiteCpp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlitecpp RENAME copyright)
