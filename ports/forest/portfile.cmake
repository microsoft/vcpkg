include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorz57/forest
    REF bc6b82ce436dfbf60d6e8882252c55cf923ad99e
    SHA512 e711148025c40fb73e6ae221fe5a4416bea006994d9ff958d565cd3cefa75c9ee7241087c7470ecb6530be073ac9171fe724351898ecd33db61f5752c3a950bc
    HEAD_REF master
)

# Handle headers
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forest RENAME copyright)
