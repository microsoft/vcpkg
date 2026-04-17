vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bernedom/SI
    REF "${VERSION}"
    SHA512 72f656b2cf5adebed94b0038241d2d39e1391c05d09ddb3a19022a8c1734534850c55d123f7d236745472fd29f6417e3d61107b94c1a50e3da7cb92c5bfa6b39
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSI_INSTALL_LIBRARY=ON
        -DSI_BUILD_TESTING=OFF
        -DSI_BUILD_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SI CONFIG_PATH share/SI/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
