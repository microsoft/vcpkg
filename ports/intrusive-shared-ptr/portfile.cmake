set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gershnik/intrusive_shared_ptr
    REF "v${VERSION}"
    SHA512 0c76f04f9fec491cc8a1fc790248c3787b893459ca14cd1953fe1abe3cd5afd275627acac141bac3bc5f039a9e47448aafe246a5e7adb2aec5038057e5102fe8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/isptr PACKAGE_NAME isptr)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
