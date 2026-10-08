set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_hive
    REF c1c3838e763bbf247b3c407d1eb2f1c59ec8527b
    SHA512 b98277fd334d6942d4e866a281539a16840693973ccc8160111f6e1855fbce9fe7a167860231f3b2fdfea699a9f4708b5eabb4904a291313898cd5f464266756
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/plf_hive.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.md"
)
