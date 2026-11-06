# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 69deaf564669ed0b61a97ee6c669b754b179de4a6d49e67ac12f1c309c945a0f76309c9ee4cc2698f384e567345be789b3735ed7e16acc6dc13eed5567ca7011
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
