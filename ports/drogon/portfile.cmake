vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drogonframework/drogon
    REF "v${VERSION}"
    SHA512 b76455116d453711052fae418b7a95934fa0822b1db9a85c567a9cf5d1fdf8c59df852bef0a481515d9eb4ce8267d1882e080c1bd003e4102234f4a7b51f77b5
    HEAD_REF master
    PATCHES
         0001-vcpkg.patch
         0002-drogon-config.patch
         0003-deps-redis.patch
         0004-drogon-ctl.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ctl      BUILD_CTL
        mysql    BUILD_MYSQL
        orm      BUILD_ORM
        postgres BUILD_POSTGRESQL
        postgres LIBPQ_BATCH_MODE
        redis    BUILD_REDIS
        sqlite3  BUILD_SQLITE
        yaml     BUILD_YAML_CONFIG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DUSE_SUBMODULE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Drogon)

vcpkg_fixup_pkgconfig()

# Copy drogon_ctl
if("ctl" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES _drogon_ctl drogon_ctl AUTO_CLEAN)
endif()

# Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Copy pdb files
vcpkg_copy_pdbs()
