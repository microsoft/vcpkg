vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/datasketches/cpp/${VERSION}/apache-datasketches-cpp-${VERSION}-src.zip"
    FILENAME "apache-datasketches-cpp-${VERSION}-src.zip"
    SHA512 98ce350e63fff02ac1ab39005a808ad0ab0b308f0807464db235fe9e6cb6dd8f5081494bd0aca85eeec5216f6a6a23280b732e714da9ad6f53690dd9da9c430c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME DataSketches CONFIG_PATH lib/DataSketches/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
