set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gershnik/intrusive_shared_ptr
    REF "v${VERSION}"
    SHA512 ba4a3e88368219893ff03e803ba8f03c4bf61e7bd5ff1e5b50fdfa67cc8756719f5ba4ac77a9dd7fe7a5db03c33a51bfb74b7c6bb8100376a0e7c8c22a8690f1
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
