# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF dd762b861ecadf5ddd5fb03e9ca1db6707b54fbb
    SHA512 4ec10ea1d9622879b5bdb61a11768e36b56a558d32aac6f8c8a52168ab401f9d53db0eeba074fe56de39f3809fb0bd73e2e6c5ef4ea8fd158abeb45e18285f08
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Put the licence file where vcpkg expects it
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
