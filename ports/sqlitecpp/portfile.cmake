include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF 453baa10f1ee05ba498a01c70f7424f044281678
    HEAD_REF master
    SHA512 113593b2e8abe45b2bb28082898907d34369b9e74730248de0be5b81c6a7febc9ee80749e6acc526ac98def02876ec0dc6e638a14d043e9b8cfff7b1c1e95609)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/0001-Find-external-sqlite3.patch)

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
