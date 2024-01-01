# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 6b7c16190fa5106dde76cbedddc42ed0a4a97fcc606dc0b962744fdc812ac81f59a21b6cf071e3a8661c58cb9de2654a4eabd03c4f44d6091f99175887735c41
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADERS "${SOURCE_PATH}/src/*.hpp"  "${SOURCE_PATH}/src/mlpack/*.hpp")
file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
