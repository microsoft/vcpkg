vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KDAB/KDSoap/releases/download/kdsoap-${VERSION}/kdsoap-${VERSION}.tar.gz"
    FILENAME "kdsoap-${VERSION}.tar.gz"
    SHA512 6ed5cd6a0d02a9faf6881facbd28391c553b3671512153ecd058ab53bfbe9d3f0afa3704d580e66010ddf6a3de7e578a632339f8c1ae7529c28f9d5fd7d1eb5f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KDSoap_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKDSoap_QT6=ON
        -DKDSoap_STATIC=${KDSoap_STATIC}
        -DKDSoap_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KDSoap-qt6 CONFIG_PATH lib/cmake/KDSoap-qt6)

vcpkg_copy_tools(TOOL_NAMES kdwsdl2cpp-qt6 AUTO_CLEAN)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
