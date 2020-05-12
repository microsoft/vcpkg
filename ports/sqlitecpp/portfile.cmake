vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "SRombauts/SQLiteCpp"
    REF be1a8eeace02ce98dfa3da688d1011c5bb895985 #v3.0.0
    HEAD_REF master
    SHA512 d48b5915a2674f7f6da2737fa365e2202373e95cd20e819281b765a597e2fa8b8ae33f6553d65b6a8a93741e31633de3c75caf84fffa4313154c43ce634b1323
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
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
