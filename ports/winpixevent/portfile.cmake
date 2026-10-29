vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/WinPixEventRuntime/${VERSION}"
    FILENAME "winpixevent.${VERSION}.zip"
    SHA512 1ae497fe84760d42176ba0f0c6e6e975f7c1ba3be1799fb1416810ea37244f5506098f7454a9831855ae76a2becff48aed9c3dca8934048124c88bd86eeb149f
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(PIX_ARCH ARM64)
else()
    set(PIX_ARCH x64)
endif()

file(GLOB HEADER_FILES "${PACKAGE_PATH}/include/WinPixEventRuntime/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(VCPKG_TARGET_IS_UWP)
    set(WINPIXEVENTRUNTIME WinPixEventRuntime_UAP)
else()
    set(WINPIXEVENTRUNTIME WinPixEventRuntime)
endif()

file(INSTALL "${PACKAGE_PATH}/bin/${PIX_ARCH}/${WINPIXEVENTRUNTIME}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${PACKAGE_PATH}/bin/${PIX_ARCH}/${WINPIXEVENTRUNTIME}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

file(INSTALL "${PACKAGE_PATH}/bin/${PIX_ARCH}/${WINPIXEVENTRUNTIME}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${PACKAGE_PATH}/bin/${PIX_ARCH}/${WINPIXEVENTRUNTIME}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

configure_file("${CMAKE_CURRENT_LIST_DIR}/winpixevent-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/license.txt")
