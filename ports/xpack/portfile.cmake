# xpack - Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyz347/xpack
    REF f7985ea64426d09f9c3d65558e905b7773f9de2e
    SHA512 db4793536648084868c6645306d89026e7fefddc9875dcacb6e44abf7513ff1ce690f41681a35503ba6ad0ab5510ca80418065216a1c2d8f40df6114c1eee2ab
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
