set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 12455e05adb23fdb843f8b24da9afba5c5bd8505
    SHA512 5530150802917f440b73558c3297519ef5eb653e00ae64e72e05e9a39e2f447254739e3c5d3b0d5dd40f617215d6f8a0cc5ce4e0600c2e056c1935a450865c38
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/plf_colony.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
