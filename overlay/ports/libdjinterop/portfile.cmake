vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/xsco/libdjinterop/archive/0.14.5.zip"
    FILENAME "libdjinterop-0.14.5.zip"
    SHA512 46cae538992f4ef6c86e71ae8dd7eca4f74891505672afcece3058eb18089baffbe81563f56cbc5f702bea940684c0aad1f5b3086751a2972cace433135b2fc9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIBDJINTEROP_OPTIONS -DBUILD_SHARED_LIBS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${LIBDJINTEROP_OPTIONS}
)

vcpkg_install_cmake()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libdjinterop RENAME copyright)
