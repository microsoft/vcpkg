# xpack - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyz347/xpack
    REF "v${VERSION}"
    SHA512 2c74e0ede211603266470177c90619a5826504e23d91922daf97e9e1a1c1e8448bc748ce2494cc552442a1531f0f94a5692cabe53c83a65f7e11a1bbe67e7065
    HEAD_REF master
)

file(GLOB header_files 
    "${SOURCE_PATH}/*.h"
    "${SOURCE_PATH}/*.hpp") 
file(COPY ${header_files}
	"${SOURCE_PATH}/xpack.pri"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
