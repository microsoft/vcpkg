# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF 8e10d4e8e7febafce0632810262e81e853b2065f #v0.11.2
    SHA512 a213edb3f24c3147879b0500df2baf8819ac39c7943ee01bf096fbae512b81694c1b7805cfae15918ef5820ee10316de268e71c3fe25d1f8cfb39dd384678f1c
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/httplib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
