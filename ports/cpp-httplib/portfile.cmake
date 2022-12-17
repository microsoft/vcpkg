# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.11.3
    SHA512 b0c46bf11c8bc84ab52143559ff1c4682b02504921855e5cd7e82bc65a04b192281ef7a124c7c7dfe928ae3842d5065097b6a4608be1c74dc51b563b15b93d0f
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/httplib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
