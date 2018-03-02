#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF v1.1.0
    SHA512 aaa
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)

# Copy the rapidjson header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
