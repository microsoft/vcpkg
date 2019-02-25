# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cbeck88/strict-variant
    REF 5ab330edcb5e3eea67fbedf8ac89648e5bc1e9a1
    SHA512 c80e5cd7cff389174447f5825af57ddea079956b2a4cb89337479e02289e89df19713ff031e914bdff2c823e8d2518311a1118701ae4e173f6557c770e553cd0
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/strict-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/strict-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/strict-variant/copyright)
