# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF fde69298dce9d29c13eac272d34216e972bfb2fc
    SHA512 fe39cee7ccfaa36df005fe86c3f2bb5e917974a1c11d5c5ea48e1075b650373c0bca172f7069b5f7dc95e8c3b1425b5dc365b6a9b89eea5f41f6aafacfe352e6
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)