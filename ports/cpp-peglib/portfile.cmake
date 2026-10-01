#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-peglib
    REF "v${VERSION}"
    SHA512 d18ff85fcec00866a2f013a63b66dd8949bc8d77282fc9b71daaa3c1c8faa57642a1e15b6572b4883902a49b82c3339ab2b9f1bb56e5e78d292d8e788e91049d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/peglib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cpp-peglib" RENAME copyright)
