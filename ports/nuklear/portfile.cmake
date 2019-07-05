include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF 509c75b086351e82865f26a507235b60a63e1538
    SHA512 d86fe93a8da8db955ccd28b353c19ea92aeb54efcf7a47ca160a576f4d52dbedc3abf7d547387a066851928c4f43c961b1daff097b3677a118c89f247042336a
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
