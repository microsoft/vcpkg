#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DLTcollab/sse2neon
    REF v1.5.1
    SHA512  7d14b074aa5829e218a04975d96fc67adba3fb4ffd9d580ab0bc05048f7abd9143dd308b2d9e8b1600b00427b21b24d49d7a6670c91270fcc6d053c3bca908af
    HEAD_REF master
)

# Copy header file
file(COPY "${SOURCE_PATH}/sse2neon.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sse2neon/")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
