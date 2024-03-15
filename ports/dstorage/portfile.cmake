
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.DirectStorage/${VERSION}"
    FILENAME "directstorage.${VERSION}.zip"
    SHA512 f24f681edf0c5e047573c68ca85ab62e0ffefaf87867d45231d779e9bc8e9525891b56314cc30e58eaef20132335f011f32aba22654d2e7caf23338aeb29c6ce
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${PACKAGE_PATH}/native/include/dstorage.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${PACKAGE_PATH}/native/include/dstorageerr.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${PACKAGE_PATH}/native/lib/${VCPKG_TARGET_ARCHITECTURE}/dstorage.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${PACKAGE_PATH}/native/bin/${VCPKG_TARGET_ARCHITECTURE}/dstorage.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(INSTALL "${PACKAGE_PATH}/native/bin/${VCPKG_TARGET_ARCHITECTURE}/dstoragecore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")
endif()

set(lib_name dstorage.lib)
configure_file("${CMAKE_CURRENT_LIST_DIR}/dstorage-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")
