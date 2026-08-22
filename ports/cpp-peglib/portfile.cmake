#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-peglib
    REF "v${VERSION}"
    SHA512 ca13d755a59586f36f5efe14c3e7002c1b61c624b630eafd832a1fcfa819cbac09329b071f812c681ba195657710a8b44ca409448ac3c982f4dce819da83ce1b
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/peglib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cpp-peglib" RENAME copyright)
