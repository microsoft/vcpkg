vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hoshimoe/NekoEvent
    REF v1.0.2
    SHA512 65dc87a7ca3c3b1b4ae7d5ef04342dc7c314784a8a3ccdb08fac7def8fbf2c9ef7ec8c44148e5bf9060e84356d3545a58a501067ee7ff0572320483dc8c4ed5c
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_EVENT_BUILD_TESTS=OFF
        -DNEKO_EVENT_AUTO_FETCH_DEPS=OFF
        -DNEKO_EVENT_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoEvent PACKAGE_NAME nekoevent)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
