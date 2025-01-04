# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihui/ruapu
    REF "${VERSION}"
    SHA512 efc74fde9e08637a5a888cfcbca000c1e7fe8095be5e59415c54c535cc2be496a4efe8aa66aac5dfbb1ae3385ba7762eb8bfd83ddbdf21720c7561707c287e45
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/ruapu.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
