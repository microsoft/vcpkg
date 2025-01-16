vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(XPSDK_VERSION "401")
vcpkg_download_distfile(
    XPLANE_SDK_ZIP
    URLS "https://developer.x-plane.com/wp-content/plugins/code-sample-generation/sdk_zip_files/XPSDK${XPSDK_VERSION}.zip"
    FILENAME "XPSDK${XPSDK_VERSION}.zip"
    SHA512 8e00789befd15f5b1cb4f426ddf9c3f7f021c5fba50b907e8af5fbf09abbc362804b5d1543332855d01e8ae91b9c50a55933e63df6e11e88e58c10ca8f949bf4
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
