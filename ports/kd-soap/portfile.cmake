vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/KDAB/KDSoap/releases/download/kdsoap-${VERSION}/kdsoap-${VERSION}.tar.gz"
    FILENAME "kdsoap-${VERSION}.tar.gz"
    SHA512 12224f664dcae7ceb7395a7c3de48a208ae81c10f6fba4d0db233613472c6b9cdbea6375297c27b58fe7338d7db27a4447844f4e8f40a24ec1b4dd3fa38d20bb
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        Ensure-KDSoapConfig-finds-Qt-first.patch
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

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
