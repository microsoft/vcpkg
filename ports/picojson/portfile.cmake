
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/picojson-rel-v1.3.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/kazuho/picojson/archive/rel/v1.3.0.zip"
    FILENAME "picojson-1.3.0.zip"
    SHA512 d1da5748b6a03e92ca4fa475a918842f5eede955f747359fa4d9d85f9ed9efac8b3748a306c2f9f71b9924099ba5e1f8f949e50cdf6f26bc3778865121725ddf
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/picojson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/picojson/LICENSE ${CURRENT_PACKAGES_DIR}/share/picojson/copyright)

# Copy the header files
file(INSTALL ${SOURCE_PATH}/picojson.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/picojson)

vcpkg_copy_pdbs()

