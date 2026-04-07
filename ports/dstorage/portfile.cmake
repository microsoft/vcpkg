# Set VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY instead of using `vcpkg_check_linkage` because
# these DLLs don't link with a CRT.
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.DirectStorage/${VERSION}"
    FILENAME "directstorage.${VERSION}.zip"
    SHA512 589a83194e9e05654523b9ca10401982d235dbaa991c8535807d5b9f851d877281417d79a0210f77b46c0f65114f805f4a12f04b7bdb3de8a00fe20c78def791
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64|arm64ec")
    set(DS_ARCH arm64)
else()
    set(DS_ARCH ${VCPKG_TARGET_ARCHITECTURE})
endif()

file(INSTALL "${PACKAGE_PATH}/native/include/dstorage.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${PACKAGE_PATH}/native/include/dstorageerr.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${PACKAGE_PATH}/native/lib/${DS_ARCH}/dstorage.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${PACKAGE_PATH}/native/bin/${DS_ARCH}/dstorage.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/native/bin/${DS_ARCH}/dstoragecore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
file(COPY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")

configure_file("${CMAKE_CURRENT_LIST_DIR}/dstorage-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
