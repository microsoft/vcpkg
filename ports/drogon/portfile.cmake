vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drogonframework/drogon
    REF "v${VERSION}"
    SHA512 19108dc00cfe0ca46eb45e1c47808ba742f41626407ced322202c417a1ce159e787fbe54c435c6543790df6ee97447875555d4a81cfcfd55bb82a2778e57cf4b
    HEAD_REF master
    PATCHES
         0001-vcpkg.patch
         0002-drogon-config.patch
         0003-deps-redis.patch
         0004-drogon-ctl.patch
         0005-jsoncpp-static.patch
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
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Drogon)

vcpkg_fixup_pkgconfig()

# Copy drogon_ctl
if("ctl" IN_LIST FEATURES)
    set(ctl_tool_names _drogon_ctl drogon_ctl)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        # Upstream also installs dg_ctl, a symlink to drogon_ctl in the same directory
        list(APPEND ctl_tool_names dg_ctl)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${ctl_tool_names} AUTO_CLEAN)
endif()

# Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/orm_lib/COPYING"
)

# Copy pdb files
vcpkg_copy_pdbs()
