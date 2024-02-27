vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/x86-simd-sort
    REF "v${VERSION}"
    SHA512 9713413b5d368cdcc066db6161a63ffe35e1d8986f417c88cb1eb91426c8b9aec4481c4dac003b8721c279575d79e7b1182c7ea78dcbdb96e41b04863a715284
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
