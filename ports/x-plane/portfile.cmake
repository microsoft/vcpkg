vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "." "" XPSDK_VERSION "${VERSION}")
vcpkg_download_distfile(
    XPLANE_SDK_ZIP
    URLS "https://developer.x-plane.com/wp-content/plugins/code-sample-generation/sdk_zip_files/XPSDK${XPSDK_VERSION}.zip"
    FILENAME "XPSDK${XPSDK_VERSION}.zip"
    SHA512 3ad66ce34b9e1e6dfba0c4547f3976b4a9862bdea0c498f43f3eedfb164d4e1b357e631b72b572b7646bffaa4ffe38698000a63dea1ae8f4c50c4037b8b6471a
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${XPLANE_SDK_ZIP}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-x-plane-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-x-plane)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
