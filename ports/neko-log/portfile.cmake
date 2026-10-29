vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoLog
    REF v1.0.8
    SHA512 6fe1e2566809508ad3ae6cf542246c7482eb674c9504288099fdc941ae290fa5aa63e889b82c2cd9ecec9c31ea87effba15b867240c896cdeacc5c7057e22d3e
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_LOG_BUILD_TESTS=OFF
        -DNEKO_LOG_AUTO_FETCH_DEPS=OFF
        -DNEKO_LOG_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoLog PACKAGE_NAME nekolog)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
