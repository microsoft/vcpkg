set(NUGET_VERSION 0.2303.22621.3038)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.GameInput/${NUGET_VERSION}"
    FILENAME "gameinput.${NUGET_VERSION}.zip"
    SHA512 4ad0e8a2ff14e498632557c64cdcd967c6b166b405b2c60427578a5f8b32b925184a1c74bce95a7a73a129e61edddbec030c4abe4ada287a2ce9ae50178cdcea
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${PACKAGE_PATH}/native/include/gameinput.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${PACKAGE_PATH}/native/lib/${VCPKG_TARGET_ARCHITECTURE}/gameinput.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")

configure_file("${CMAKE_CURRENT_LIST_DIR}/gameinput-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
