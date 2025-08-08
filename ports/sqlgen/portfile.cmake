vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/sqlgen
    REF "v${VERSION}"
    SHA512 fa38b8e669d11fc21195911cf0669d1bcb192200006d0d784e0725a27d8c65668ec974097cd0470dd340dc05cc833734e8dc51773a87b8c61a7849761b6cf3af 
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SQLGEN_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mariadb             SQLGEN_MYSQL
        postgres            SQLGEN_POSTGRES
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLGEN_BUILD_TESTS=OFF
        -DSQLGEN_SQLITE3=ON
        -DSQLGEN_BUILD_SHARED=${SQLGEN_BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
