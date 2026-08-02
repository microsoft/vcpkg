# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 1b5bd899c82391f098b53b10077e592b0be7fb50ea443c15963b2676a5221e606907dfd8eabbd498b4b1effe000b2e8b606ad99690cd81dd0e97d39de38148b5
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
