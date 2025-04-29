# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 c615e47319dd9e777ab23a1f0898d49e6974c4c097c7271c97702648ba03152f9320a74b4cf3d4b8d3f403c416715859ef8e70687b22455ca07e934f2645c013
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
