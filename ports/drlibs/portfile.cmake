# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF 877b0967ce679148f60d69bb2d9173487717d8de
    SHA512 ed4eafbac1d3591604476f9deb2701acb874c72f50d89694bba1536273fe662aa81b0e2d44bece75be1d153d602cf8da0720bcfc07969967800607b1ad28cde5
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
