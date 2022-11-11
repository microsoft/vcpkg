vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.Direct3D.DirectStorage/${VERSION}"
    FILENAME "directstorage.${VERSION}.zip"
    SHA512 2c2cf6486220f99e7447c1a4406cea6fcaea69edccf790df6887acfde9a684e102547016adadd1ca23f17f8f02bfbd39095892ed63fba3e806bfa44ca9fe0fe6
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL "${PACKAGE_PATH}/native/include/dstorage.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${PACKAGE_PATH}/native/include/dstorageerr.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${PACKAGE_PATH}/native/lib/${VCPKG_TARGET_ARCHITECTURE}/dstorage.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(COPY "${PACKAGE_PATH}/native/bin/${VCPKG_TARGET_ARCHITECTURE}/dstorage.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/native/bin/${VCPKG_TARGET_ARCHITECTURE}/dstoragecore.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
file(COPY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${PACKAGE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/dstorage-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
