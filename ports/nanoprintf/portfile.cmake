# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 4b0dffdbb0dc98b5e48b6f0d1d8a39407899a1601a47a4688879c6d47398c65bbe11ae4a06f70ee66d5c600ca0fad859cd11359be906181c722479555ec05ae1
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
