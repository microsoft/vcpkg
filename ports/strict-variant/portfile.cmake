# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cbeck88/strict-variant
    REF 70cb9469b78028d72da1409d631d72a75ed7d498
    SHA512 d1cd2ece2b5b099344f307fea5103c5136eae0b4dd3b30957a1bb7ed8c60d372ddcc721681475c35f17f50ad897b8f6019e381b50ebf7b19a82276de2c6033e1
    HEAD_REF master
)

# Copy header files
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/strict-variant)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/strict-variant/LICENSE ${CURRENT_PACKAGES_DIR}/share/strict-variant/copyright)
