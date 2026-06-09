#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-peglib
    REF "v${VERSION}"
    SHA512 01351a0496e112013c3009273b7ba1f5436ded1442b1dbbd0a2d895c8155c7602a8e2d1d907d6acc3edbe8587d5572eb8d06e40d78aa52fee5b900425081a026
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/peglib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cpp-peglib" RENAME copyright)
