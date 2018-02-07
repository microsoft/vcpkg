include(vcpkg_common_functions)

set(LIB_NAME nghttp2)
set(LIB_VERSION 1.29.0)

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.gz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIB_NAME}-${LIB_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nghttp2/nghttp2/releases/download/v${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 34dfda7ba637fb23b24141aacf8a0c342a369a59c84d4e2bfed9b5a867f85a5d1d950267f018a820645954406d70bf499f01e2f9b1ebaa4b76e8f47c3693fd6e
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/enable-static.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_LIB_ONLY=ON
        -DENABLE_ASIO_LIB=OFF
)

vcpkg_install_cmake()

# Remove unwanted files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

# Move dll files from /lib to /bin where vcpkg expects them
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/bin/${LIB_NAME}.dll)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/debug/bin/${LIB_NAME}.dll)
endif()

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
