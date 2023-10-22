set(SHAPELIB_VERSION 1.5.0)
set(SHAPELIB_HASH 230939afb33aee042808a32b38ee9dfc7ec1f39432e5a4ebe3fda99c2f87bfbebc91830d4e21691c51aae3f4bb65d7e71e7061472bb08124dcd3402c46800d6c)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/shapelib/shapelib-${SHAPELIB_VERSION}.zip"
    FILENAME "shapelib-${SHAPELIB_VERSION}.zip"
    SHA512 ${SHAPELIB_HASH}
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        option-build-test.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME shp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/shapelib")
    file(REMOVE ${EXES})
endif()

file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(DEBUG_EXES)
    file(REMOVE ${DEBUG_EXES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/shapelib")

vcpkg_copy_pdbs()
