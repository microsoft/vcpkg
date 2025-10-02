# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF 3141b54b6b0067d15c4a3ec0877f2141a2a11347
    SHA512 4f0cc42843fde19d5fdc59b684530201fc6d396d73e1b3c45eb7bededff552213467e441b6674673848b49b8172ee5ce88ed959cedb7893db117fe93cd1e06b7
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
