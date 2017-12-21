include(vcpkg_common_functions)

set(LIB_NAME nghttp2)
set(LIB_VERSION 1.28.0)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message("nghttp2 doesn't currently support static library build")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
    if(VCPKG_CRT_LINKAGE STREQUAL static)
        message(FATAL_ERROR "avoiding building DLL with static CRT.")
    endif()
endif()

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.gz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIB_NAME}-${LIB_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nghttp2/nghttp2/releases/download/v${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 37fbc7fe5f7292ea17ec030f024de0a697ede3ea883457b7edebfb0f21c7eee9196c62df61945953b54b410eea3a64d180beeb477529bd744caf986be0a1b1c9
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
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
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/bin/${LIB_NAME}.dll)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/debug/bin/${LIB_NAME}.dll)
endif()

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
