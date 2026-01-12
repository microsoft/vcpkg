# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF 1d7bfaf0c3821c820164a7a6b2742523503a2ce3
    SHA512 89eb5a86f6c5480f90a2ece234d306c6d464e78f53f2d59b107d9fbab9f990c9e220f58365cca6c0faa226fc621d16bd49266406bec5090aa43f696b37e62dd7
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
