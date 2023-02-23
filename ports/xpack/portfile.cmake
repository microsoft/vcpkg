# xpack - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyz347/xpack
    REF 137467c05badd88b8569d161f27afb498ea4ff9a
    SHA512 349ff9fb9ca74bd1401d8f0f121b263e40c021fde57a500d31eb14eeba8f3d3e8d7f6f629fc696d3052095d311700aa42b7b3a0a19c61787246e6680ea27928e
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
