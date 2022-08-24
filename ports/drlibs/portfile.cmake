# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF c729134b41cf09542542b5da841ac2f933b36cba
    SHA512 3760a5921d120db21c9351e7edf1877b7052783e20dd7f6ab673992db0f6e4014c07c559f993f7870f6e7fe021b5e47b10b27ea0ed3895d07077b0eea8e13078
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Put the licence file where vcpkg expects it
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
