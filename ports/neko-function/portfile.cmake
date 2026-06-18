vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoFunction
    REF v1.0.11
    SHA512 3fbdba19085d76fe747ec38a2a4ad1e41c5d67f0e5ae320982bde35f796c9d89cbd304e6b11ef1bb4fa7101698f3b6737c6ddf94bd7f46f8f4e4061ef132c6ce
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        archive  NEKO_FUNCTION_ENABLE_ARCHIVE
        hash     NEKO_FUNCTION_ENABLE_HASH
)

if("archive" IN_LIST FEATURES)
    set(NEKO_FUNCTION_IS_HEADER_ONLY FALSE)
else()
    set(NEKO_FUNCTION_IS_HEADER_ONLY TRUE)
endif()

if(NEKO_FUNCTION_IS_HEADER_ONLY)
    set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNEKO_FUNCTION_BUILD_TESTS=OFF
        -DNEKO_FUNCTION_AUTO_FETCH_DEPS=OFF
        -DNEKO_FUNCTION_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoFunction PACKAGE_NAME nekofunction)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(NEKO_FUNCTION_IS_HEADER_ONLY)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
