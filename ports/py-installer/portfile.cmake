vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pypa/installer
    REF b1d39180f8548820d09ce992dfadff0a42242c48
    SHA512 09beb22bde94f2a5ec8c164d16af6322d9d05c6ec98507538070a9ab4f161802fc068c5e31540f4adf92c574488f3e0f94dc31e3bf58c09eac4096a8096bf873
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/src/installer" DESTINATION "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_python_test_import(MODULE "installer")
