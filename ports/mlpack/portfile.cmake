# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 2ae159a4aa8340be4763944c1b1e460f4d8fe838c79325cffdcacfbac340cca4cec3031493caec7e9b4dcf6fc921cbd93c1384d7e1954492fe410c83d3e615f8
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
