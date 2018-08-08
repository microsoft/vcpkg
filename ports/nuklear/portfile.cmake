include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vurtun/nuklear
    REF aeb18269131ab2c8d579aab935e15a8f4b040e38
    SHA512 174595cb9c196af2c7648b6f88d43f66585a97fd99e3147c2ab2e371821a1b56cf60178a1aef53ee09afb9213548993cff6be615a32c5c16dca1e0858c19e162
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/nuklear.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/Readme.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/nuklear RENAME copyright)
vcpkg_copy_pdbs()
