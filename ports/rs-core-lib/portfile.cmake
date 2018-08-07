include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/rs-core-lib
    REF 989a68109c28c8a4c9352fd166809f63f2e92ce4
    SHA512 e4b0b0e20ffc67ed737fd26db9860d111f0a59e9d98b0350f5997225b0536768d9987f0fb75fdb08516b36e266ad11c1a0bd3bab7c14eb65ee18e5cd90ff03cb
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/rs-core DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hpp")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rs-core-lib RENAME copyright)