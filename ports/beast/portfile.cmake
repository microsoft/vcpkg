# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 7fb75d0627f7842a6a706b810d427962509e0e52
    SHA512 5d086d2edf18facc3f379c42ffcc2679f9c03f891d58f2c8e6cb1a9aa6ee73b232544d1c2a86ce9c42dbc9a41a58bd3480f958cc1c569e8b3b1890755ecfd7fc
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)