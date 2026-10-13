vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stescobedo92/swagger-cpp
    REF v0.4.0
    SHA512 39641e620b159c5e0bd50ab41b7451a13373e4086d0889f4c355871b1d2ca94b320a22706a2757b98101df038dea6918cf060822f17430e9454b40956b3a1961
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools SWAGGERCPP_BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSWAGGERCPP_BUILD_TESTS=OFF
        -DSWAGGERCPP_BUILD_BENCHMARKS=OFF
        -DSWAGGERCPP_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME swaggercpp CONFIG_PATH lib/cmake/swaggercpp)
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES swaggercpp-cli AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
