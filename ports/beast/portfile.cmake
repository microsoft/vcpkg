# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 3f8097b6fddce8463084ce5c0d69db9a9079c2b8
    SHA512 843cc0ddea35987e4f5eeaabcbcf3317135979eec9645a324740afa2a0af5041af787ee05e14d55d2ce17c72e227eacbadbe87c49e1bb6d7a0b075ad9694d92d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)