vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REF 9b4128ee1153e78288a1b5433e2c06a0d47a4c4e
    REPO zer0mem/cccapstone
    SHA512 d0023586281f921314dbba501fa2c06d822b1adba0a0c32f30b78628ee935e5822caebe3881a5d1cc4cc696b82a7e348044d887a7f652303359d2853d2ee45fb
    HEAD_REF master
    PATCHES fix-include-path.patch
)

file(INSTALL ${SOURCE_PATH}/cppbindings/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/cccapstone/cppbindings)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/cccapstone RENAME copyright)
