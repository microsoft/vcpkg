# xpack - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyz347/xpack
    REF fc9b7808b1f0de81d8c1fa307a04ebe122b30650
    SHA512 d989da44e5e2f8e32202e5f5d6f5292f88b386cb6cf9d898e74267977f1254d08672773a62378c2cf4c2d72c724ad1e87d019a170d14acbd675c0ca1edbe5e77
    HEAD_REF master
)

file(GLOB header_files 
    "${SOURCE_PATH}/*.h"
    "${SOURCE_PATH}/*.hpp") 
file(COPY ${header_files}
    "${SOURCE_PATH}/thirdparty"
	"${SOURCE_PATH}/xpack.pri"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
