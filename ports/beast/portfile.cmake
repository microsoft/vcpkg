# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF 8ba182cb2e0d073724be170cb64cd3d9226f161f
    SHA512 e8f776aaac1f79f40cc06df0abc76e68da4aa502a66fe0b8a1a51f7c8d1245ee9fe4b767e398415f582b6f79df00711b91c60b688c574a06794e7c860a1775dc
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)