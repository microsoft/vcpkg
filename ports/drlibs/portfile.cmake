# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mackron/dr_libs
    REF d35a3bc5efd02455d98cbe12b94647136f09b42d
    SHA512 34126c8eb65f0735b77f058db9f1618b3c4e820698804b47f7a629c47df571e9cbbeefd4cce193409ebd715d37ed5faf1c3c27a7240e0f5418089cffe853f1ea
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
