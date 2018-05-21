include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF eb5c851f4e82d31692d7c45225b41fdc374134aa
    SHA512 e1a3a8cd16f069c8c58858dfe516df0aa2dd07f4e415a2ef7539104024910383217f75c16481347ef0a92a17faad98aa051320ec9e4693426ad9cd297983d923
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)