#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/rapidjson-1.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/miloyip/rapidjson/archive/v1.1.0.zip"
    FILENAME "v1.1.0.zip"
    SHA512 4ddbf6dc5d943eb971e7a62910dd78d1cc5cc3016066a443f351d4276d2be3375ed97796e672c2aecd6990f0b332826f8c8ddc7d367193d7b82f0037f4e4012c
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)

# Copy the rapidjson header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
