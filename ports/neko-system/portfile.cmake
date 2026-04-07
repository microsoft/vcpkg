vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoSystem
    REF v1.0.1
    SHA512 6ae5af6be464c7e0cfada4a87ac349537d0083dfaa8c02f421917525ceb62331632c3c203baedadaff44a7129817311cf5c72045e6b99e97b7bc17efeb2f475e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNEKO_SYSTEM_BUILD_TESTS=OFF
        -DNEKO_SYSTEM_AUTO_FETCH_DEPS=OFF
        -DNEKO_SYSTEM_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoSystem PACKAGE_NAME nekosystem)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
