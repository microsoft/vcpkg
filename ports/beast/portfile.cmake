# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 32902fad8b7c57be27b96e00ed6ec82748732133
    SHA512 55d1ccff105f997ab7b607528980161baf22aff56109e368a6232f3cfe1fbbf3f060e2b88d68f00728e75b951b60291b8cd6d56a3e299208e6cd757cb53bd774
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)
