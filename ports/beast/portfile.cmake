# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 6a8912a88ba94dd28aa11b086faaf32a11c3fbf7
    SHA512 0fa23fabe75c4a26bb2da3505df96f3a9382d8fda614dc618c1dec075eae790fd83849bc59884e17aa0811af0b06c401a8c5929f8060dbfd5044c350f7ad90be
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)