# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.9.7
    SHA512 7c12ff7b5cfba1a814cb14bdc28c949a97817668e1e6cee030fe1ea5e8748460677908ddb83fd1d06d96dd79a910004071076d1486d39103b6280f628ba38e2d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/httplib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
