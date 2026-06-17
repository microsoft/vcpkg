# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF fa931f3285ced10ace628f7f1ac951e1951e7ea6
    SHA512 a1422ac827334d9e4adcbb7bc9b51244659c1c6e07b8e5ab3af2b82c5ac4842c4fb54a6a19d02e287eb2a8c3f470f556b2d111e23f10cae83a7ffb4e36ebc04f
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
