#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-peglib
    REF "v${VERSION}"
    SHA512 83fc5ab31899d969ca5cc3ffc7b7db6ac8b36358b83f69c0bdea5abd1e5ca1b319a7e4b99fec4dbe1008daaa2eec6ca010d00567a2278bd43d6d712f3ecaaebd
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/peglib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/cpp-peglib" RENAME copyright)
