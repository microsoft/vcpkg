set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapnik/polylabel
    REF "v${VERSION}"
    SHA512 e01a34e6c5e3d93fce105ef63fe26bc247bb2433db3b87068feda27da761d2a6fb948c246885d2573fb05d3706994a5543226837ce5e4f0499011cd86acc19e4
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/mapbox/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mapbox" FILES_MATCHING PATTERN "*.hpp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
