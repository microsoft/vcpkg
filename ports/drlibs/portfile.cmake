# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF f13cbcfd06afe7287f99b1bb5982cefdf3d6a974
    SHA512 c108db409389f912bdcb979bc0dfe31658b8bcd7ce327145a77bdb9a168512e2c1a94cb59677b5d6bfa213e412498360a8ec25d5424bb2ba292edaf88bf5f195
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Put the licence file where vcpkg expects it
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
