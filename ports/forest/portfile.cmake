include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF 8.2.0
    SHA512 737a491b585443b5beeee8eb252d4a4253b872dbef0dcfca33ae0d3ea3935e189de3a84dbdb6fe8d91a18a4bde07023de05cd39e3bd0fb226775bec38ee685be
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
