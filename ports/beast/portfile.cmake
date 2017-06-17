# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 4e4bcf8b1114229713eec0cf5fd392e5bdd76717
    SHA512 514b93dccd483b1b847d9274f8a6fe9f4c32fdae6e1c45410abd3bb3554fa901aac8d6fc666a76420e1c4fa729e2ce7f95afa459faf01614de41995040eeb7bb
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)