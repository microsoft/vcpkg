vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO an-tao/drogon
    REF "v${VERSION}"
    SHA512 39cbb337d1b83d2202fff8bf43e9173060d1cfc8384369aa3d86e63ac2bfca9b8c3bec4bcf48f8c400788791fbfeccb0cd934cb7b26d95ef12981b4227206726
    HEAD_REF master
    PATCHES
         0001-vcpkg.patch
         0002-drogon-config.patch
         0003-deps-redis.patch
         0004-drogon-ctl.patch
         0005-drogon-cross-compile.patch
)

set(DROGON_CTL_TOOL "")
if(VCPKG_CROSSCOMPILING)
    set(DROGON_CTL_TOOL "${CURRENT_HOST_INSTALLED_DIR}/tools/drogon/drogon_ctl${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

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

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DROGON_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_DROGON_SHARED}
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
        -DUSE_SUBMODULE=OFF
        "-DDROGON_CTL_TOOL=${DROGON_CTL_TOOL}"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_Boost
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

# Fix CMake files
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Drogon)

vcpkg_fixup_pkgconfig()

# Copy drogon_ctl
if("ctl" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES drogon_ctl AUTO_CLEAN)
endif()

# Remove includes in debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy pdb files
vcpkg_copy_pdbs()
