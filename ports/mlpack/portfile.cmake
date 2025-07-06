# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF "${VERSION}"
    SHA512 20db99f792d7c12caa6ba149538363f05e713fc4ef25cfdad5807223b8379ae7529e2a2f31cbe79fcd45a9bd6bb12d6ef91ffc5d5f144768153aca6eeed8184e
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
