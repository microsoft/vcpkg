#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF v1.1.0
    SHA512 2e82a4bddcd6c4669541f5945c2d240fb1b4fdd6e239200246d3dd50ce98733f0a4f6d3daa56f865d8c88779c036099c52a9ae85d47ad263686b68a88d832dff
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)

# Copy the rapidjson header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")
vcpkg_copy_pdbs()
