# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF 9452c0a4b69c5e4e31169ed32e961d330695122c   #v0.10.7
    SHA512 23c4ca159ed4ddf29c3911436436502df76420d8bc8b202f290627de96ee6a741b74409a90f943f3fbbb59af1975bd8c36a94bd4c5eff3981f4514feb326e110
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/httplib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
