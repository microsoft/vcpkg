# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 3ca6a621f14c99202e18eb61defd90420e230791a057ee9d9f8299630904a052da91208bd30ebbb080fd9bc49296a8a9f9fdb023b0408c0d4859792b8929f970
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADERS_SRC "${SOURCE_PATH}/src/*.hpp")
file(GLOB HEADERS_MLPACK "${SOURCE_PATH}/src/mlpack/*.hpp")
file(COPY ${HEADERS_SRC} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY ${HEADERS_MLPACK} DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
